//
//  RecipeViewModel.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//

import Combine
import Foundation
import SwiftUI

@MainActor
class RecipeViewModel: ObservableObject {

    // MARK: - List State
    @Published var myRecipes: [Recipe] = []
    @Published var isLoading: Bool = false

    // 🚀 Error state
    @Published var operationError: String = ""

    // MARK: - Detail UI State
    @Published var currentTab: DetailTab = .ingredients
    @Published var favoriteRecipeIds: Set<String> = []  // State nyata untuk Favorites

    // MARK: - Collection Bottom Sheet State
    @Published var showCollectionSheet: Bool = false
    @Published var userCollections: [RecipeCollection] = []
    @Published var selectedCollectionIds: Set<String> = []
    @Published var selectedRecipeForCollection: Recipe? = nil  // Melacak resep mana yang akan disimpan
    @Published var isSavingToCollections: Bool = false

    enum DetailTab {
        case ingredients
        case steps
    }

    private let recipeService = RecipeService.shared
    private let collectionService = CollectionService.shared
    private let authService = AuthService.shared
    
    // 🚀 KUNCI PERBAIKAN: Penyimpanan bersama (Shared Cache) & Combine untuk sinkronisasi antar objek ViewModel
    private static var sharedFavoriteIds: Set<String> = []
    private var cancellables = Set<AnyCancellable>()

    // MARK: - INITIALIZER
    init() {
        // 1. Langsung samakan data begitu ViewModel baru lahir (Mencegah hati kosong saat buka detail dari Profile)
        self.favoriteRecipeIds = Self.sharedFavoriteIds
        
        // 2. Dengarkan sinyal jika ada instance lain yang mengubah status favorite
        NotificationCenter.default.publisher(for: .favoritesUpdated)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.favoriteRecipeIds = Self.sharedFavoriteIds
            }
            .store(in: &cancellables)
            
        // 3. Ambil data terbaru dari server di background untuk memastikan akurasi data
        Task {
            await loadFavoriteIds()
        }
    }

    // Helper untuk menghapus error (Sangat berguna jika View ingin menutup Alert)
    func clearError() {
        self.operationError = ""
    }

    // MARK: - Helpers
    /// Pastikan recipe punya ID yang stabil sebelum dipakai untuk favorite / collection.
    /// Untuk resep TheMealDB, idealnya id = idMeal.
    private func normalizedRecipeForPersistence(_ recipe: Recipe) -> Recipe? {
        var normalized = recipe

        // Jika id nil, kita tidak bisa simpan favorite secara konsisten.
        guard let rid = normalized.id,
            !rid.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            return nil
        }

        // Pastikan userId terisi untuk membedakan sumber.
        if normalized.userId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            normalized.userId = "themealdb"
        }

        return normalized
    }

    // MARK: - Core CRUD Methods
    func loadMyRecipes() async {
        guard let uid = authService.getCurrentUID() else { return }
        isLoading = true
        operationError = ""
        do {
            myRecipes = try await recipeService.getUserRecipes(userId: uid)
            await loadFavoriteIds()  // Muat juga data favorit saat memuat resep
        } catch {
            self.operationError = error.localizedDescription
        }
        isLoading = false
    }

    func createRecipe(
        title: String,
        description: String,
        category: String,
        ingredients: [String],
        steps: [String],
        imageData: Data?
    ) async -> Bool {
        isLoading = true
        operationError = ""
        guard let uid = authService.getCurrentUID() else { return false }

        let cleanedIngredients = ingredients.filter {
            !$0.trimmingCharacters(in: .whitespaces).isEmpty
        }
        let cleanedSteps = steps.filter {
            !$0.trimmingCharacters(in: .whitespaces).isEmpty
        }
        let newRecipe = Recipe(
            userId: uid,
            title: title,
            description: description,
            ingredients: cleanedIngredients,
            steps: cleanedSteps,
            category: category,
            recipeImage: ""
        )

        do {
            try await recipeService.createRecipe(
                recipe: newRecipe,
                imageData: imageData
            )
            await loadMyRecipes()
            isLoading = false
            return true
        } catch {
            self.operationError = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func updateRecipe(
        recipeId: String,
        title: String,
        description: String,
        category: String,
        ingredients: [String],
        steps: [String],
        oldImageURL: String,
        newImageData: Data?,
        isImageDeleted: Bool
    ) async -> Bool {
        isLoading = true
        operationError = ""
        guard let uid = authService.getCurrentUID() else { return false }

        let cleanedIngredients = ingredients.filter {
            !$0.trimmingCharacters(in: .whitespaces).isEmpty
        }
        let cleanedSteps = steps.filter {
            !$0.trimmingCharacters(in: .whitespaces).isEmpty
        }
        let finalImageURL = isImageDeleted ? "" : oldImageURL

        var updatedRecipe = Recipe(
            userId: uid,
            title: title,
            description: description,
            ingredients: cleanedIngredients,
            steps: cleanedSteps,
            category: category,
            recipeImage: finalImageURL
        )
        updatedRecipe.id = recipeId

        do {
            try await recipeService.updateRecipe(
                recipe: updatedRecipe,
                newImageData: newImageData
            )
            await loadMyRecipes()
            isLoading = false
            return true
        } catch {
            self.operationError = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func deleteRecipe(recipe: Recipe) async {
        guard let recipeId = recipe.id else { return }
        do {
            try await recipeService.deleteRecipe(recipeId: recipeId)
            myRecipes.removeAll { $0.id == recipeId }
        } catch {
            print("Error deleting recipe: \(error.localizedDescription)")
        }
    }

    // MARK: - Ownership
    func isOwner(recipe: Recipe) -> Bool {
        return recipe.userId == authService.getCurrentUID()
    }

    // MARK: - 🌟 FAVORITES LOGIC
    func loadFavoriteIds() async {
        guard let uid = authService.getCurrentUID() else { return }
        do {
            let ids = try await recipeService.getFavoriteRecipeIds(userId: uid)
            // 🚀 Simpan ke static cache dan lokal secara bersamaan
            Self.sharedFavoriteIds = Set(ids)
            self.favoriteRecipeIds = Self.sharedFavoriteIds
        } catch {
            print("Error loading favorites: \(error.localizedDescription)")
        }
    }

    func isFavorite(recipe: Recipe) -> Bool {
        guard let recipeId = recipe.id else { return false }
        return favoriteRecipeIds.contains(recipeId)
    }

    func toggleFavorite(recipe: Recipe) async {
        guard let uid = authService.getCurrentUID() else { return }

        guard let normalized = normalizedRecipeForPersistence(recipe),
              let recipeId = normalized.id else {
            print("toggleFavorite aborted: recipe.id is nil/empty")
            return
        }

        let isCurrentlyFavorite = favoriteRecipeIds.contains(recipeId)
        let willBeFavorite = !isCurrentlyFavorite

        // OPTIMISTIC UPDATE: Ubah data lokal
        if willBeFavorite {
            favoriteRecipeIds.insert(recipeId)
        } else {
            favoriteRecipeIds.remove(recipeId)
        }
        
        // 🚀 UPDATE STATIC CACHE: Amankan agar data langsung sinkron ke semua screen
        Self.sharedFavoriteIds = favoriteRecipeIds

        NotificationCenter.default.post(name: .favoritesUpdated, object: nil)

        do {
            if willBeFavorite && normalized.userId == "themealdb" {
                try? await recipeService.createRecipe(
                    recipe: normalized,
                    imageData: nil
                )
            }

            try await recipeService.toggleFavorite(
                userId: uid,
                recipeId: recipeId,
                isFavorite: willBeFavorite
            )
        } catch {
            // ROLLBACK jika database Firestore gagal merespon
            if isCurrentlyFavorite {
                favoriteRecipeIds.insert(recipeId)
            } else {
                favoriteRecipeIds.remove(recipeId)
            }
            
            // 🚀 ROLLBACK STATIC CACHE
            Self.sharedFavoriteIds = favoriteRecipeIds
            
            NotificationCenter.default.post(name: .favoritesUpdated, object: nil)
            print("Error toggling favorite: \(error.localizedDescription)")
        }
    }

    // MARK: - 🌟 COLLECTION SHEET LOGIC
    func openCollectionSheet(for recipe: Recipe) async {
        selectedRecipeForCollection = recipe
        selectedCollectionIds.removeAll()
        showCollectionSheet = true
        await fetchUserCollections()
    }

    func fetchUserCollections() async {
        guard let uid = authService.getCurrentUID() else { return }
        do {
            userCollections = try await collectionService.getUserCollections(
                userId: uid
            )
        } catch {
            print("Error fetching collections: \(error.localizedDescription)")
        }
    }

    func toggleCollectionSelection(collectionId: String) {
        if selectedCollectionIds.contains(collectionId) {
            selectedCollectionIds.remove(collectionId)
        } else {
            selectedCollectionIds.insert(collectionId)
        }
    }

    func saveToSelectedCollections() async {
        guard let rawRecipe = selectedRecipeForCollection,
            let normalized = normalizedRecipeForPersistence(rawRecipe),
            let recipeId = normalized.id
        else { return }

        isSavingToCollections = true

        do {
            if normalized.userId == "themealdb" {
                try? await recipeService.createRecipe(
                    recipe: normalized,
                    imageData: nil
                )
            }

            for collectionId in selectedCollectionIds {
                try await collectionService.addRecipeToCollection(
                    collectionId: collectionId,
                    recipeId: recipeId
                )
            }
            showCollectionSheet = false
            selectedCollectionIds.removeAll()
            selectedRecipeForCollection = nil
        } catch {
            self.operationError = error.localizedDescription
        }
        isSavingToCollections = false
    }
}

extension Notification.Name {
    static let favoritesUpdated = Notification.Name("favoritesUpdated")
}

// MARK: - Mock Data Extension
extension Recipe {
    static let mockRecipes = [
        Recipe(
            userId: "123",
            title: "Mom's Sunday Pasta",
            description: "Delicious pasta",
            ingredients: ["Pasta"],
            steps: ["Boil water"],
            category: "Italian",
            recipeImage:
                "https://www.themealdb.com/images/media/meals/sutysw1468247559.jpg"
        ),
        Recipe(
            userId: "123",
            title: "Blueberry Pavlova",
            description: "Sweet dessert",
            ingredients: ["Blueberry"],
            steps: ["Bake"],
            category: "Dessert",
            recipeImage:
                "https://www.themealdb.com/images/media/meals/adxcjq1628770918.jpg"
        ),
    ]
}

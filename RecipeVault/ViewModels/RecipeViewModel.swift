//
//  RecipeViewModel.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class RecipeViewModel: ObservableObject {
    
    // MARK: - List State
    @Published var myRecipes: [Recipe] = []
    @Published var isLoading: Bool = false
    
    // 🚀 Error state
    @Published var operationError: String = ""
    
    // MARK: - Detail UI State
    @Published var currentTab: DetailTab = .ingredients
    @Published var favoriteRecipeIds: Set<String> = [] // State nyata untuk Favorites
    
    // MARK: - Collection Bottom Sheet State
    @Published var showCollectionSheet: Bool = false
    @Published var userCollections: [RecipeCollection] = []
    @Published var selectedCollectionIds: Set<String> = []
    @Published var selectedRecipeForCollection: Recipe? = nil // Melacak resep mana yang akan disimpan
    @Published var isSavingToCollections: Bool = false
    
    enum DetailTab {
        case ingredients
        case steps
    }
    
    private let recipeService = RecipeService.shared
    private let collectionService = CollectionService.shared
    private let authService = AuthService.shared
    
    // MARK: - Core CRUD Methods
    func loadMyRecipes() async {
        guard let uid = authService.getCurrentUID() else { return }
        isLoading = true
        operationError = ""
        do {
            myRecipes = try await recipeService.getUserRecipes(userId: uid)
            await loadFavoriteIds() // Muat juga data favorit saat memuat resep
        } catch {
            self.operationError = error.localizedDescription
        }
        isLoading = false
    }
    
    func createRecipe(title: String, description: String, category: String, ingredients: [String], steps: [String], imageData: Data?) async -> Bool {
        isLoading = true
        operationError = ""
        guard let uid = authService.getCurrentUID() else { return false }
        
        let cleanedIngredients = ingredients.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let cleanedSteps = steps.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let newRecipe = Recipe(userId: uid, title: title, description: description, ingredients: cleanedIngredients, steps: cleanedSteps, category: category, recipeImage: "")
        
        do {
            try await recipeService.createRecipe(recipe: newRecipe, imageData: imageData)
            await loadMyRecipes()
            isLoading = false
            return true
        } catch {
            self.operationError = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func updateRecipe(recipeId: String, title: String, description: String, category: String, ingredients: [String], steps: [String], oldImageURL: String, newImageData: Data?, isImageDeleted: Bool) async -> Bool {
        isLoading = true
        operationError = ""
        guard let uid = authService.getCurrentUID() else { return false }
        
        let cleanedIngredients = ingredients.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let cleanedSteps = steps.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let finalImageURL = isImageDeleted ? "" : oldImageURL
        
        var updatedRecipe = Recipe(userId: uid, title: title, description: description, ingredients: cleanedIngredients, steps: cleanedSteps, category: category, recipeImage: finalImageURL)
        updatedRecipe.id = recipeId
        
        do {
            try await recipeService.updateRecipe(recipe: updatedRecipe, newImageData: newImageData)
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
            self.favoriteRecipeIds = Set(ids)
        } catch {
            print("Error loading favorites: \(error.localizedDescription)")
        }
    }
    
    func isFavorite(recipe: Recipe) -> Bool {
        guard let recipeId = recipe.id else { return false }
        return favoriteRecipeIds.contains(recipeId)
    }
    
    func toggleFavorite(recipe: Recipe) async {
        guard let uid = authService.getCurrentUID(), let recipeId = recipe.id else { return }
        
        let isCurrentlyFavorite = favoriteRecipeIds.contains(recipeId)
        let willBeFavorite = !isCurrentlyFavorite
        
        // Optimistic UI Update: Langsung ubah warna UI sebelum server membalas
        if willBeFavorite { favoriteRecipeIds.insert(recipeId) }
        else { favoriteRecipeIds.remove(recipeId) }
        
        do {
            // 🚀 JIKA RESEP DARI THEMEALDB DIFAVORITKAN, SIMPAN SALINANNYA KE FIRESTORE
            if willBeFavorite && recipe.userId == "themealdb" {
                try? await recipeService.createRecipe(recipe: recipe, imageData: nil)
            }
            
            try await recipeService.toggleFavorite(userId: uid, recipeId: recipeId, isFavorite: willBeFavorite)
        } catch {
            // Jika Firebase gagal, kembalikan warna hati seperti semula
            if isCurrentlyFavorite { favoriteRecipeIds.insert(recipeId) }
            else { favoriteRecipeIds.remove(recipeId) }
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
            userCollections = try await collectionService.getUserCollections(userId: uid)
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
        guard let recipe = selectedRecipeForCollection, let recipeId = recipe.id else { return }
        isSavingToCollections = true
        
        do {
            // 🚀 JIKA RESEP DARI THEMEALDB DISIMPAN KE KOLEKSI, SIMPAN SALINANNYA KE FIRESTORE
            // Kita mengirimkan imageData: nil, sehingga URL aslinya (http...) tetap utuh.
            if recipe.userId == "themealdb" {
                // Menggunakan try? agar tidak crash jika resep sudah pernah tersimpan sebelumnya
                try? await recipeService.createRecipe(recipe: recipe, imageData: nil)
            }
            
            for collectionId in selectedCollectionIds {
                try await collectionService.addRecipeToCollection(collectionId: collectionId, recipeId: recipeId)
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

// MARK: - Mock Data Extension
extension Recipe {
    static let mockRecipes = [
        Recipe(userId: "123", title: "Mom's Sunday Pasta", description: "Delicious pasta", ingredients: ["Pasta"], steps: ["Boil water"], category: "Italian", recipeImage: "https://www.themealdb.com/images/media/meals/sutysw1468247559.jpg"),
        Recipe(userId: "123", title: "Blueberry Pavlova", description: "Sweet dessert", ingredients: ["Blueberry"], steps: ["Bake"], category: "Dessert", recipeImage: "https://www.themealdb.com/images/media/meals/adxcjq1628770918.jpg")
    ]
}

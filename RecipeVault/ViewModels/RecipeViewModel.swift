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
    @Published var operationError: String = ""
    
    // MARK: - Detail UI State
    @Published var currentTab: DetailTab = .ingredients
    @Published var favoriteRecipeIds: Set<String> = []
    
    // MARK: - Collection Bottom Sheet State
    @Published var showCollectionSheet: Bool = false
    @Published var userCollections: [RecipeCollection] = []
    
    // 🚀 STATE BARU: Untuk melacak perubahan centang kotak
    @Published var selectedCollectionIds: Set<String> = []
    @Published var originalCollectionIds: Set<String> = [] // Menyimpan data asli sebelum diedit
    
    @Published var selectedRecipeForCollection: Recipe? = nil
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
            await loadFavoriteIds()
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
        
        if willBeFavorite { favoriteRecipeIds.insert(recipeId) }
        else { favoriteRecipeIds.remove(recipeId) }
        
        do {
            if willBeFavorite && recipe.userId == "themealdb" {
                try? await recipeService.createRecipe(recipe: recipe, imageData: nil)
            }
            try await recipeService.toggleFavorite(userId: uid, recipeId: recipeId, isFavorite: willBeFavorite)
        } catch {
            if isCurrentlyFavorite { favoriteRecipeIds.insert(recipeId) }
            else { favoriteRecipeIds.remove(recipeId) }
            print("Error toggling favorite: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 🌟 COLLECTION SHEET LOGIC
    func openCollectionSheet(for recipe: Recipe) async {
        selectedRecipeForCollection = recipe
        selectedCollectionIds.removeAll()
        originalCollectionIds.removeAll()
        
        showCollectionSheet = true
        await fetchUserCollections()
        
        // 🚀 Cek di database apakah resep ini sudah ada di folder
        if let recipeId = recipe.id {
            do {
                let existingColIds = try await collectionService.getCollectionIdsForRecipe(recipeId: recipeId)
                
                // Pastikan hanya mencentang koleksi milik user yang sedang login
                let userColIds = Set(userCollections.compactMap { $0.id })
                let validIds = Set(existingColIds).intersection(userColIds)
                
                // Centang UI otomatis
                self.selectedCollectionIds = validIds
                self.originalCollectionIds = validIds
            } catch {
                print("Error loading checked collections: \(error.localizedDescription)")
            }
        }
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
            // Auto-clone jika TheMealDB (Hanya dipanggil jika ditambah ke folder baru)
            if recipe.userId == "themealdb" && !selectedCollectionIds.isEmpty {
                try? await recipeService.createRecipe(recipe: recipe, imageData: nil)
            }
            
            // 🚀 LOGIKA DIFFING: Tentukan mana yang ditambah, mana yang dihapus
            let collectionsToAdd = selectedCollectionIds.subtracting(originalCollectionIds)
            let collectionsToRemove = originalCollectionIds.subtracting(selectedCollectionIds)
            
            // 1. Eksekusi Penambahan
            for collectionId in collectionsToAdd {
                try await collectionService.addRecipeToCollection(collectionId: collectionId, recipeId: recipeId)
            }
            
            // 2. Eksekusi Penghapusan (Jika user "uncheck" folder yang tadinya dicentang)
            for collectionId in collectionsToRemove {
                try await collectionService.removeRecipeFromCollection(collectionId: collectionId, recipeId: recipeId)
            }
            
            showCollectionSheet = false
            selectedCollectionIds.removeAll()
            originalCollectionIds.removeAll()
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
        Recipe(userId: "123", title: "Mom's Sunday Pasta", description: "Delicious pasta", ingredients: ["Pasta"], steps: ["Boil water"], category: "Italian", recipeImage: "https://www.themealdb.com/images/media/meals/sutysw1468247559.jpg")
    ]
}

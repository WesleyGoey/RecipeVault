//
//  RecipeViewModel.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


// MARK: - RecipeViewModel
import Foundation
import SwiftUI
import Combine

@MainActor
class RecipeViewModel: ObservableObject {
    
    // MARK: - List State
    @Published var myRecipes: [Recipe] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    
    // MARK: - Detail UI State
    @Published var isFavorite: Bool = false
    @Published var currentTab: DetailTab = .ingredients
    
    // MARK: - Collection Bottom Sheet State
    @Published var showCollectionSheet: Bool = false
    @Published var userCollections: [RecipeCollection] = []
    @Published var selectedCollectionIds: Set<String> = []
    @Published var isSavingToCollections: Bool = false
    
    enum DetailTab {
        case ingredients
        case steps
    }
    
    private let firestoreRepo = FirestoreRepository.shared
    private let collectionService = CollectionService.shared
    private let authService = AuthService.shared
    
    // MARK: - Core CRUD Methods
        func loadMyRecipes() async {
            guard let uid = authService.getCurrentUID() else { return }
            isLoading = true
            do {
                // 🚀 PERBAIKAN: Ambil data asli dari Firebase, bukan Mock Data!
                myRecipes = try await RecipeService.shared.getUserRecipes(userId: uid)
            } catch {
                self.errorMessage = error.localizedDescription
            }
            isLoading = false
        }
        
        // MARK: - Create
        func createRecipe(title: String, description: String, category: String, ingredients: [String], steps: [String], imageData: Data?) async -> Bool {
            isLoading = true
            guard let uid = authService.getCurrentUID() else { return false }
            
            let cleanedIngredients = ingredients.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            let cleanedSteps = steps.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            
            let newRecipe = Recipe(userId: uid, title: title, description: description, ingredients: cleanedIngredients, steps: cleanedSteps, category: category, recipeImage: "")
            
            do {
                try await RecipeService.shared.createRecipeWithImage(recipe: newRecipe, imageData: imageData)
                await loadMyRecipes() // Refresh UI
                isLoading = false
                return true
            } catch {
                self.errorMessage = error.localizedDescription
                isLoading = false
                return false
            }
        }
        
        // MARK: - Update
        func updateRecipe(recipeId: String, title: String, description: String, category: String, ingredients: [String], steps: [String], oldImageURL: String, newImageData: Data?) async -> Bool {
            isLoading = true
            guard let uid = authService.getCurrentUID() else { return false }
            
            let cleanedIngredients = ingredients.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            let cleanedSteps = steps.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            
            var updatedRecipe = Recipe(userId: uid, title: title, description: description, ingredients: cleanedIngredients, steps: cleanedSteps, category: category, recipeImage: oldImageURL)
            updatedRecipe.id = recipeId // Pastikan ID tidak berubah
            
            do {
                try await RecipeService.shared.updateRecipeWithImage(recipe: updatedRecipe, newImageData: newImageData)
                await loadMyRecipes() // Refresh UI
                isLoading = false
                return true
            } catch {
                self.errorMessage = error.localizedDescription
                isLoading = false
                return false
            }
        }
        
        // MARK: - Delete
        func deleteRecipe(recipe: Recipe) async {
            guard let recipeId = recipe.id else { return }
            do {
                // 🚀 PERBAIKAN: Hapus dari Firebase!
                try await RecipeService.shared.deleteRecipe(recipeId: recipeId)
                myRecipes.removeAll { $0.id == recipeId }
            } catch {
                print("Error deleting recipe: \(error.localizedDescription)")
            }
        }
    
    // MARK: - Ownership & Interaction
    func isOwner(recipe: Recipe) -> Bool {
        return recipe.userId == authService.getCurrentUID()
    }
    
    func toggleFavorite(recipe: Recipe) async {
        isFavorite.toggle()
        // TODO: Call FavoriteService to add/remove favorite
    }
    
    func checkIfFavorite(recipe: Recipe) async {
        // TODO: Check Firestore if this is already favorited
    }
    
    // MARK: - Collection Sheet Methods
    func openCollectionSheet() async {
        showCollectionSheet = true
        await fetchUserCollections()
    }
    
    func fetchUserCollections() async {
        guard let uid = authService.getCurrentUID() else { return }
        do {
            userCollections = try await firestoreRepo.getUserCollections(userId: uid)
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
    
    func saveToSelectedCollections(recipe: Recipe) async {
        guard let recipeId = recipe.id else { return }
        isSavingToCollections = true
        
        do {
            for collectionId in selectedCollectionIds {
                try await collectionService.addRecipeToCollection(collectionId: collectionId, recipeId: recipeId)
            }
            showCollectionSheet = false
            selectedCollectionIds.removeAll()
        } catch {
            print("Error saving to collections: \(error.localizedDescription)")
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

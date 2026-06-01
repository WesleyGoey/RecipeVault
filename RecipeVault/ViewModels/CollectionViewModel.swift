//
//  CollectionViewModel.swift
//  RecipeVault
//
//  Created by Nicholas Gerwin Mawardji on 29/05/26.
//


import Foundation
import SwiftUI
import Combine

// MARK: - CollectionViewModel Class
@MainActor
class CollectionViewModel: ObservableObject {
    private let collectionService = CollectionService.shared
    private let authService = AuthService.shared
    
    @Published var myCollections: [RecipeCollection] = []
    @Published var recipesInCollection: [Recipe] = []
    @Published var collectionCounts: [String: Int] = [:]
    
    @Published var isLoading: Bool = false
    @Published var operationError: String = ""
    
    // MARK: - Collection Section
    
    // MARK: - Load My Collections
    func loadMyCollections() async {
        guard let uid = authService.getCurrentUID() else { return }
        isLoading = true
        operationError = ""
        
        do {
            let fetchedCollections = try await collectionService.getUserCollections(userId: uid)
            
            var tempCounts: [String: Int] = [:]
            
            for collection in fetchedCollections {
                if let colId = collection.id {
                    let count = (try? await collectionService.getRecipeCountInCollection(collectionId: colId)) ?? 0
                    tempCounts[colId] = count
                }
            }
            
            self.myCollections = fetchedCollections
            self.collectionCounts = tempCounts
            
        } catch {
            self.operationError = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Create Collection
    func createCollection(name: String, description: String, visibility: Visibility, imageData: Data?) async -> Bool {
        guard let uid = authService.getCurrentUID() else { return false }
        isLoading = true
        operationError = ""
        
        let newCol = RecipeCollection(userId: uid, name: name, description: description, collectionImage: "", visibility: visibility)
        
        do {
            try await collectionService.createCollection(collection: newCol, imageData: imageData)
            await loadMyCollections()
            isLoading = false
            return true
        } catch {
            self.operationError = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    // MARK: - Update Collection
    func updateCollection(collectionId: String, name: String, description: String, visibility: Visibility, oldImageURL: String, newImageData: Data?, isImageDeleted: Bool) async -> Bool {
        guard let uid = authService.getCurrentUID() else { return false }
        isLoading = true
        operationError = ""
        
        let finalImageURL = isImageDeleted ? "" : oldImageURL
        var updatedCol = RecipeCollection(userId: uid, name: name, description: description, collectionImage: finalImageURL, visibility: visibility)
        updatedCol.id = collectionId
        
        do {
            try await collectionService.updateCollection(collection: updatedCol, newImageData: newImageData)
            await loadMyCollections()
            isLoading = false
            return true
        } catch {
            self.operationError = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    // MARK: - Delete Collection
    func deleteCollection(collection: RecipeCollection) async {
        guard let collectionId = collection.id else { return }
        isLoading = true
        do {
            try await collectionService.deleteCollection(collectionId: collectionId)
            myCollections.removeAll { $0.id == collectionId }
        } catch {
            self.operationError = "Error deleting: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    
    // MARK: - Recipe Section
    
    // MARK: - Load Recipes For Collection
    func loadRecipesForCollection(collectionId: String) async {
        isLoading = true
        operationError = ""
        do {
            recipesInCollection = try await collectionService.getRecipesInCollection(collectionId: collectionId)
        } catch {
            self.operationError = error.localizedDescription
        }
        isLoading = false
    }
    
    // MARK: - Remove Recipe From Collection
    func removeRecipeFromCollection(recipe: Recipe, from collection: RecipeCollection) async {
        guard let collectionId = collection.id, let recipeId = recipe.id else { return }
        do {
            try await collectionService.removeRecipeFromCollection(collectionId: collectionId, recipeId: recipeId)
            recipesInCollection.removeAll { $0.id == recipeId }
        } catch {
            self.operationError = error.localizedDescription
        }
    }
    
    
    // MARK: - Utilities
    
    // MARK: - Check Ownership
    func isOwner(collection: RecipeCollection) -> Bool {
        return collection.userId == authService.getCurrentUID()
    }
}

// MARK: - Mock Data Extension
extension RecipeCollection {
    static let mockCollections = [
        RecipeCollection(userId: "123", name: "Weeknight Favorites", description: "Quick and easy recipes for busy weekdays.", collectionImage: "mock_image_1", visibility: .publicVisibility),
        RecipeCollection(userId: "123", name: "Summer BBQ", description: "Best grilling recipes.", collectionImage: "mock_image_2", visibility: .privateVisibility),
        RecipeCollection(userId: "123", name: "Keto Essentials", description: "Low carb high fat meals.", collectionImage: "mock_image_3", visibility: .publicVisibility),
        RecipeCollection(userId: "123", name: "Date Night Dinners", description: "Fancy meals for two.", collectionImage: "mock_image_4", visibility: .privateVisibility)
    ]
}

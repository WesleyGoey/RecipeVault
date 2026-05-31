//
//  CollectionViewModel.swift
//  RecipeVault
//
//  Created by Nicholas Gerwin Mawardji on 29/05/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class CollectionViewModel: ObservableObject {
    
    @Published var myCollections: [RecipeCollection] = []
    @Published var recipesInCollection: [Recipe] = []
    @Published var collectionCounts: [String: Int] = [:]
    
    @Published var isLoading: Bool = false
    
    // 🚀 REVISI: Mengubah errorMessage menjadi operationError agar konsisten dengan ViewModel lain
    @Published var operationError: String = ""
    
    private let collectionService = CollectionService.shared
    private let authService = AuthService.shared
    
    // MARK: - READ
    func loadMyCollections() async {
        guard let uid = authService.getCurrentUID() else { return }
        isLoading = true
        operationError = ""
        
        do {
            // 1. Ambil data koleksi dari Firebase
            let fetchedCollections = try await collectionService.getUserCollections(userId: uid)
            
            // 2. Buat dictionary sementara untuk menghindari render berulang yang menyebabkan bug angka 0
            var tempCounts: [String: Int] = [:]
            
            // Ambil jumlah resep untuk setiap koleksi
            for collection in fetchedCollections {
                if let colId = collection.id {
                    let count = (try? await collectionService.getRecipeCountInCollection(collectionId: colId)) ?? 0
                    tempCounts[colId] = count
                }
            }
            
            // 3. Update State secara serentak. Ini akan memaksa UI (CollectionsView) untuk refresh dengan akurat
            self.myCollections = fetchedCollections
            self.collectionCounts = tempCounts
            
        } catch {
            self.operationError = error.localizedDescription
        }
        
        isLoading = false
    }
    
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
    
    // MARK: - CREATE
    func createCollection(name: String, description: String, visibility: Visibility, imageData: Data?) async -> Bool {
        guard let uid = authService.getCurrentUID() else { return false }
        isLoading = true
        operationError = ""
        
        let newCol = RecipeCollection(userId: uid, name: name, description: description, collectionImage: "", visibility: visibility)
        
        do {
            try await collectionService.createCollection(collection: newCol, imageData: imageData)
            await loadMyCollections() // Langsung refresh UI
            isLoading = false
            return true
        } catch {
            self.operationError = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    // MARK: - UPDATE
    func updateCollection(collectionId: String, name: String, description: String, visibility: Visibility, oldImageURL: String, newImageData: Data?, isImageDeleted: Bool) async -> Bool {
        guard let uid = authService.getCurrentUID() else { return false }
        isLoading = true
        operationError = ""
        
        let finalImageURL = isImageDeleted ? "" : oldImageURL
        var updatedCol = RecipeCollection(userId: uid, name: name, description: description, collectionImage: finalImageURL, visibility: visibility)
        updatedCol.id = collectionId
        
        do {
            try await collectionService.updateCollection(collection: updatedCol, newImageData: newImageData)
            await loadMyCollections() // Langsung refresh UI
            isLoading = false
            return true
        } catch {
            self.operationError = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    // MARK: - DELETE
    func deleteCollection(collection: RecipeCollection) async {
        guard let collectionId = collection.id else { return }
        isLoading = true
        do {
            try await collectionService.deleteCollection(collectionId: collectionId)
            myCollections.removeAll { $0.id == collectionId } // Hapus instan dari UI
        } catch {
            self.operationError = "Error deleting: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    // FITUR TAMBAHAN: Hapus resep dari koleksi spesifik
    func removeRecipeFromCollection(recipe: Recipe, from collection: RecipeCollection) async {
        guard let collectionId = collection.id, let recipeId = recipe.id else { return }
        do {
            try await collectionService.removeRecipeFromCollection(collectionId: collectionId, recipeId: recipeId)
            recipesInCollection.removeAll { $0.id == recipeId } // Hapus dari UI layar Detail
        } catch {
            self.operationError = error.localizedDescription
        }
    }
    
    // MARK: - Ownership
    func isOwner(collection: RecipeCollection) -> Bool {
        return collection.userId == authService.getCurrentUID()
    }
}

// MARK: - Mock Data
extension RecipeCollection {
    static let mockCollections = [
        RecipeCollection(userId: "123", name: "Weeknight Favorites", description: "Quick and easy recipes for busy weekdays.", collectionImage: "mock_image_1", visibility: .publicVisibility),
        RecipeCollection(userId: "123", name: "Summer BBQ", description: "Best grilling recipes.", collectionImage: "mock_image_2", visibility: .privateVisibility),
        RecipeCollection(userId: "123", name: "Keto Essentials", description: "Low carb high fat meals.", collectionImage: "mock_image_3", visibility: .publicVisibility),
        RecipeCollection(userId: "123", name: "Date Night Dinners", description: "Fancy meals for two.", collectionImage: "mock_image_4", visibility: .privateVisibility)
    ]
}

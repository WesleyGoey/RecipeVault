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
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    
    private let collectionService = CollectionService.shared
    private let authService = AuthService.shared
    
    // MARK: - READ
    func loadMyCollections() async {
        guard let uid = authService.getCurrentUID() else { return }
        isLoading = true
        errorMessage = ""
        do {
            myCollections = try await collectionService.getUserCollections(userId: uid)
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func loadRecipesForCollection(collectionId: String) async {
        isLoading = true
        errorMessage = ""
        do {
            recipesInCollection = try await collectionService.getRecipesInCollection(collectionId: collectionId)
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    // MARK: - CREATE
    func createCollection(name: String, description: String, visibility: Visibility, imageData: Data?) async -> Bool {
        guard let uid = authService.getCurrentUID() else { return false }
        isLoading = true
        errorMessage = ""
        
        let newCol = RecipeCollection(userId: uid, name: name, description: description, collectionImage: "", visibility: visibility)
        
        do {
            try await collectionService.createCollection(collection: newCol, imageData: imageData)
            await loadMyCollections() // Langsung refresh UI
            isLoading = false
            return true
        } catch {
            self.errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    // MARK: - UPDATE
    func updateCollection(collectionId: String, name: String, description: String, visibility: Visibility, oldImageURL: String, newImageData: Data?, isImageDeleted: Bool) async -> Bool {
        guard let uid = authService.getCurrentUID() else { return false }
        isLoading = true
        errorMessage = ""
        
        let finalImageURL = isImageDeleted ? "" : oldImageURL
        var updatedCol = RecipeCollection(userId: uid, name: name, description: description, collectionImage: finalImageURL, visibility: visibility)
        updatedCol.id = collectionId
        
        do {
            try await collectionService.updateCollection(collection: updatedCol, newImageData: newImageData)
            await loadMyCollections() // Langsung refresh UI
            isLoading = false
            return true
        } catch {
            self.errorMessage = error.localizedDescription
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
            self.errorMessage = "Error deleting: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func isOwner(collection: RecipeCollection) -> Bool {
        return collection.userId == authService.getCurrentUID()
    }
}

// MARK: - Mock Data
extension RecipeCollection {
    static let mockCollections = [
        RecipeCollection(userId: "123", name: "Weeknight Favorites", description: "Quick and easy recipes for busy weekdays.", collectionImage: "https://images.unsplash.com/photo-1556910103-1c02745aae4d?q=80&w=500&auto=format&fit=crop", visibility: .publicVisibility),
        RecipeCollection(userId: "123", name: "Summer BBQ", description: "Best grilling recipes.", collectionImage: "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?q=80&w=500&auto=format&fit=crop", visibility: .privateVisibility),
        RecipeCollection(userId: "123", name: "Keto Essentials", description: "Low carb high fat meals.", collectionImage: "https://images.unsplash.com/photo-1473093295043-cdd812d0e601?q=80&w=500&auto=format&fit=crop", visibility: .publicVisibility),
        RecipeCollection(userId: "123", name: "Date Night Dinners", description: "Fancy meals for two.", collectionImage: "https://images.unsplash.com/photo-1544025162-d76694265947?q=80&w=500&auto=format&fit=crop", visibility: .privateVisibility)
    ]
}

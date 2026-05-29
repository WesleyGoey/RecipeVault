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
    
    // MARK: - Properties
    @Published var myCollections: [RecipeCollection] = []
    @Published var recipesInCollection: [Recipe] = [] // Resep di dalam koleksi yang sedang dibuka
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    
    private let firestoreRepo = FirestoreRepository.shared
    private let collectionService = CollectionService.shared
    private let authService = AuthService.shared
    
    // MARK: - Fetch Methods
    func loadMyCollections() async {
        guard let uid = authService.getCurrentUID() else { return }
        isLoading = true
        do {
            // TODO: myCollections = try await firestoreRepo.getUserCollections(userId: uid)
            myCollections = RecipeCollection.mockCollections // Mock Data Preview
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func loadRecipesForCollection(collectionId: String) async {
        isLoading = true
        do {
            // TODO: Ambil resep berdasarkan collectionId melalui Junction Table
            recipesInCollection = Recipe.mockRecipes // Mock Data Preview
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    // MARK: - Action Methods
    func deleteCollection(collection: RecipeCollection) async {
        guard let collectionId = collection.id else { return }
        do {
            // TODO: Panggil fungsi delete di CollectionService
            myCollections.removeAll { $0.id == collectionId }
            print("Collection Deleted Successfully!")
        } catch {
            print("Error deleting collection: \(error.localizedDescription)")
        }
    }
    
    // Logika Tombol '+' untuk memasukkan resep ke dalam koleksi (dioper dari RecipeViewModel)
    func addRecipeToCollection(collectionId: String, recipeId: String) async {
        do {
            try await collectionService.addRecipeToCollection(collectionId: collectionId, recipeId: recipeId)
            print("Successfully added recipe to collection!")
        } catch {
            self.errorMessage = error.localizedDescription
        }
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

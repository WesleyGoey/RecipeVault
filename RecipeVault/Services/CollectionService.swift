//
//  CollectionService.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//

import Foundation
import UIKit

// MARK: - CollectionService Class
class CollectionService: CollectionServiceProtocol {
    static let shared = CollectionService(firestoreRepo: FirestoreRepository.shared)
    private let firestoreRepo: FirestoreRepositoryProtocol
    private let maxCollectionsPerUser = 50

    // MARK: - Initializer
    init(firestoreRepo: FirestoreRepositoryProtocol) {
        self.firestoreRepo = firestoreRepo
    }
    
    // MARK: - Collection Section

    // MARK: - Create Collection
    func createCollection(collection: RecipeCollection, imageData: Data?) async throws {
        let existingCollections = try await firestoreRepo.getUserCollections(userId: collection.userId)
        
        guard existingCollections.count < maxCollectionsPerUser else {
            throw NSError(
                domain: "CollectionService",
                code: 403,
                userInfo: [NSLocalizedDescriptionKey: "Batas maksimal 50 koleksi tercapai."]
            )
        }

        var newCollection = collection

        if let data = imageData, let uiImage = UIImage(data: data) {
            newCollection.collectionImage = Base64Helper.encode(uiImage) ?? ""
        } else {
            newCollection.collectionImage = ""
        }

        try await firestoreRepo.createCollection(collection: newCollection)
    }

    // MARK: - Get User Collections
    func getUserCollections(userId: String) async throws -> [RecipeCollection] {
        return try await firestoreRepo.getUserCollections(userId: userId)
    }

    // MARK: - Get Public Collections
    func getPublicCollections() async throws -> [RecipeCollection] {
        return try await firestoreRepo.getPublicCollections()
    }

    // MARK: - Update Collection
    func updateCollection(collection: RecipeCollection, newImageData: Data?) async throws {
        var updatedCollection = collection

        if let data = newImageData, let uiImage = UIImage(data: data) {
            updatedCollection.collectionImage = Base64Helper.encode(uiImage) ?? ""
        }

        try await firestoreRepo.updateCollection(collection: updatedCollection)
    }

    // MARK: - Delete Collection
    func deleteCollection(collectionId: String) async throws {
        try await firestoreRepo.deleteCollection(collectionId: collectionId)
    }

    
    // MARK: - Recipe Section

    // MARK: - Get Recipes In Collection
    func getRecipesInCollection(collectionId: String) async throws -> [Recipe] {
        return try await firestoreRepo.getRecipesInCollection(collectionId: collectionId)
    }

    // MARK: - Get Recipe Count In Collection
    func getRecipeCountInCollection(collectionId: String) async throws -> Int {
        return try await firestoreRepo.getRecipeCountInCollection(collectionId: collectionId)
    }

    // MARK: - Add Recipe To Collection
    func addRecipeToCollection(collectionId: String, recipeId: String) async throws {
        try await firestoreRepo.addRecipeToCollection(collectionId: collectionId, recipeId: recipeId)
    }

    // MARK: - Remove Recipe From Collection
    func removeRecipeFromCollection(collectionId: String, recipeId: String) async throws {
        try await firestoreRepo.removeRecipeFromCollection(collectionId: collectionId, recipeId: recipeId)
    }

    // MARK: - Get Collection IDs For Recipe
    func getCollectionIdsForRecipe(recipeId: String) async throws -> [String] {
        return try await firestoreRepo.getCollectionIdsForRecipe(recipeId: recipeId)
    }
}

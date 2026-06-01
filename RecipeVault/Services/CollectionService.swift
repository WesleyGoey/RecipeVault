//
//  CollectionService.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//

import Foundation
import UIKit  // 🚀 Wajib di-import agar bisa menggunakan UIImage

class CollectionService: CollectionServiceProtocol {

    // 🚀 Hapus semua dependensi ke CloudStorageRepository, kita hanya pakai Firestore
    static let shared = CollectionService(
        firestoreRepo: FirestoreRepository.shared
    )

    private let firestoreRepo: FirestoreRepositoryProtocol
    private let maxCollectionsPerUser = 50  // NFR-04

    init(firestoreRepo: FirestoreRepositoryProtocol) {
        self.firestoreRepo = firestoreRepo
    }

    // MARK: - 1. CREATE
    func createCollection(collection: RecipeCollection, imageData: Data?)
        async throws
    {
        // Cek NFR-04 Batas Koleksi
        let existingCollections = try await firestoreRepo.getUserCollections(
            userId: collection.userId
        )
        guard existingCollections.count < maxCollectionsPerUser else {
            throw NSError(
                domain: "CollectionService",
                code: 403,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Batas maksimal 50 koleksi tercapai."
                ]
            )
        }

        var newCollection = collection

        // 🚀 MENGGUNAKAN BASE64HELPER UNTUK MENYIMPAN GAMBAR
        if let data = imageData, let uiImage = UIImage(data: data) {
            // Encode menjadi Base64 string dengan kualitas 30% dan ukuran 400x400 (sesuai helper-mu)
            newCollection.collectionImage = Base64Helper.encode(uiImage) ?? ""
        } else {
            newCollection.collectionImage = ""
        }

        try await firestoreRepo.createCollection(collection: newCollection)
    }

    // MARK: - 2. READ
    func getUserCollections(userId: String) async throws -> [RecipeCollection] {
        return try await firestoreRepo.getUserCollections(userId: userId)
    }

    func getRecipesInCollection(collectionId: String) async throws -> [Recipe] {
        return try await firestoreRepo.getRecipesInCollection(
            collectionId: collectionId
        )
    }

    func getRecipeCountInCollection(collectionId: String) async throws -> Int {
        return try await firestoreRepo.getRecipeCountInCollection(
            collectionId: collectionId
        )
    }

    // MARK: - 3. UPDATE
    func updateCollection(collection: RecipeCollection, newImageData: Data?)
        async throws
    {
        var updatedCollection = collection

        // 🚀 MENGGUNAKAN BASE64HELPER JIKA USER MENGUBAH GAMBAR
        if let data = newImageData, let uiImage = UIImage(data: data) {
            updatedCollection.collectionImage =
                Base64Helper.encode(uiImage) ?? ""
        }

        try await firestoreRepo.updateCollection(collection: updatedCollection)
    }

    // MARK: - 4. DELETE
    func deleteCollection(collectionId: String) async throws {
        try await firestoreRepo.deleteCollection(collectionId: collectionId)
    }

    // MARK: - MANAGE RECIPES IN COLLECTION
    func addRecipeToCollection(collectionId: String, recipeId: String)
        async throws
    {
        try await firestoreRepo.addRecipeToCollection(
            collectionId: collectionId,
            recipeId: recipeId
        )
    }

    func removeRecipeFromCollection(collectionId: String, recipeId: String)
        async throws
    {
        try await firestoreRepo.removeRecipeFromCollection(
            collectionId: collectionId,
            recipeId: recipeId
        )
    }

    func getCollectionIdsForRecipe(recipeId: String) async throws -> [String] {
        return []
    }
}

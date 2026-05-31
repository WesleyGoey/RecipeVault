//
//  CollectionService.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//

import Foundation
// 🚀 Hapus import UIKit karena kita tidak lagi membutuhkan konversi ke UIImage untuk Base64

class CollectionService: CollectionServiceProtocol {
    
    // 🚀 EFISIENSI: Kembalikan storageRepo untuk mengelola gambar via Firebase Storage
    static let shared = CollectionService(
        firestoreRepo: FirestoreRepository.shared,
        storageRepo: CloudStorageRepository.shared
    )
    
    private let firestoreRepo: FirestoreRepositoryProtocol
    private let storageRepo: CloudStorageRepositoryProtocol
    
    private let maxCollectionsPerUser = 50 // NFR-04
    
    // MARK: - Initializer (Dependency Injection)
    init(firestoreRepo: FirestoreRepositoryProtocol, storageRepo: CloudStorageRepositoryProtocol) {
        self.firestoreRepo = firestoreRepo
        self.storageRepo = storageRepo
    }
    
    // MARK: - 1. CREATE
    func createCollection(collection: RecipeCollection, imageData: Data?) async throws {
        // 🚀 Validasi Batas Koleksi (NFR-04)
        let existingCollections = try await firestoreRepo.getUserCollections(userId: collection.userId)
        guard existingCollections.count < maxCollectionsPerUser else {
            throw NSError(
                domain: "CollectionService",
                code: 403,
                userInfo: [NSLocalizedDescriptionKey: "Batas maksimal 50 koleksi tercapai."]
            )
        }
        
        var newCollection = collection
        
        // 🚀 Jika ada gambar, upload ke Firebase Storage dan simpan URL-nya
        if let data = imageData {
            let imageURL = try await storageRepo.uploadImage(image: data, path: "collection_covers")
            newCollection.collectionImage = imageURL
        } else {
            // Fallback jika tidak ada gambar (biarkan string kosong sesuai inisialisasi)
            newCollection.collectionImage = ""
        }
        
        try await firestoreRepo.createCollection(collection: newCollection)
    }
    
    // MARK: - 2. READ
    func getUserCollections(userId: String) async throws -> [RecipeCollection] {
        return try await firestoreRepo.getUserCollections(userId: userId)
    }
    
    func getRecipesInCollection(collectionId: String) async throws -> [Recipe] {
        return try await firestoreRepo.getRecipesInCollection(collectionId: collectionId)
    }
    
    func getRecipeCountInCollection(collectionId: String) async throws -> Int {
        return try await firestoreRepo.getRecipeCountInCollection(collectionId: collectionId)
    }
    
    // MARK: - 3. UPDATE (Ubah Nama, Deskripsi, Visibilitas, Gambar)
    func updateCollection(collection: RecipeCollection, newImageData: Data?) async throws {
        var updatedCollection = collection
        
        // 🚀 Jika user mengganti gambar, upload yang baru ke Firebase Storage
        if let data = newImageData {
            let imageURL = try await storageRepo.uploadImage(image: data, path: "collection_covers")
            updatedCollection.collectionImage = imageURL
        }
        
        try await firestoreRepo.updateCollection(collection: updatedCollection)
    }
    
    // MARK: - 4. DELETE
    func deleteCollection(collectionId: String) async throws {
        try await firestoreRepo.deleteCollection(collectionId: collectionId)
    }
    
    // MARK: - MANAGE RECIPES IN COLLECTION
    func addRecipeToCollection(collectionId: String, recipeId: String) async throws {
        try await firestoreRepo.addRecipeToCollection(collectionId: collectionId, recipeId: recipeId)
    }
    
    func removeRecipeFromCollection(collectionId: String, recipeId: String) async throws {
        try await firestoreRepo.removeRecipeFromCollection(collectionId: collectionId, recipeId: recipeId)
    }
}

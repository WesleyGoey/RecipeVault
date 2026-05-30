//
//  CollectionService.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


// MARK: - CollectionService
import Foundation

class CollectionService: CollectionServiceProtocol {
    
    static let shared = CollectionService(
        firestoreRepo: FirestoreRepository.shared,
        storageRepo: CloudStorageRepository.shared // 🚀 TAMBAHKAN STORAGE
    )
    
    private let firestoreRepo: FirestoreRepositoryProtocol
    private let storageRepo: CloudStorageRepositoryProtocol
    
    private let maxCollectionsPerUser = 50 // NFR-04
    
    init(firestoreRepo: FirestoreRepositoryProtocol, storageRepo: CloudStorageRepositoryProtocol) {
        self.firestoreRepo = firestoreRepo
        self.storageRepo = storageRepo
    }
    
    private func validateSize(image: Data, maxMB: Int = 5) -> Bool {
        let sizeInMB = Double(image.count) / (1024.0 * 1024.0)
        return sizeInMB <= Double(maxMB)
    }
    
    // 1. CREATE
    func createCollection(collection: RecipeCollection, imageData: Data?) async throws {
        let existingCollections = try await firestoreRepo.getUserCollections(userId: collection.userId)
        guard existingCollections.count < maxCollectionsPerUser else {
            throw NSError(domain: "CollectionService", code: 403, userInfo: [NSLocalizedDescriptionKey: "Batas maksimal \(maxCollectionsPerUser) koleksi tercapai."])
        }
        
        var newCollection = collection
        if let data = imageData {
            guard validateSize(image: data) else { throw NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Gambar > 5MB"]) }
            newCollection.collectionImage = try await storageRepo.uploadImage(image: data, path: "collection_images")
        }
        
        try await firestoreRepo.createCollection(collection: newCollection)
    }
    
    // 2. READ
    func getUserCollections(userId: String) async throws -> [RecipeCollection] {
        return try await firestoreRepo.getUserCollections(userId: userId)
    }
    
    func getRecipesInCollection(collectionId: String) async throws -> [Recipe] {
        return try await firestoreRepo.getRecipesInCollection(collectionId: collectionId)
    }
    
    // 3. UPDATE (Ubah Nama, Deskripsi, Visibilitas, Gambar)
    func updateCollection(collection: RecipeCollection, newImageData: Data?) async throws {
        var updatedCollection = collection
        if let data = newImageData {
            guard validateSize(image: data) else { throw NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Gambar > 5MB"]) }
            updatedCollection.collectionImage = try await storageRepo.uploadImage(image: data, path: "collection_images")
        }
        try await firestoreRepo.updateCollection(collection: updatedCollection)
    }
    
    // 4. DELETE
    func deleteCollection(collectionId: String) async throws {
        try await firestoreRepo.deleteCollection(collectionId: collectionId)
    }
    
    // MARK: - Relasi
    func addRecipeToCollection(collectionId: String, recipeId: String) async throws {
        try await firestoreRepo.addRecipeToCollection(collectionId: collectionId, recipeId: recipeId)
    }
}

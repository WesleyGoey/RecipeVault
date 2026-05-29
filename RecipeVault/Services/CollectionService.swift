//
//  CollectionService.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


// MARK: - CollectionService
import Foundation

class CollectionService: CollectionServiceProtocol {
    
    // MARK: - Properties
    static let shared = CollectionService(firestoreRepo: FirestoreRepository.shared)
    private let firestoreRepo: FirestoreRepositoryProtocol
    
    // Batas koleksi sesuai NFR-04
    private let maxCollectionsPerUser = 50
    
    // MARK: - Initializer (Dependency Injection)
    init(firestoreRepo: FirestoreRepositoryProtocol) {
        self.firestoreRepo = firestoreRepo
    }
    
    // MARK: - Methods
    func createCollection(collection: RecipeCollection) async throws {
        // 1. Ambil jumlah koleksi pengguna saat ini
        let existingCollections = try await firestoreRepo.getUserCollections(userId: collection.userId)
        
        // 2. Validasi Batas NFR-04
        guard existingCollections.count < maxCollectionsPerUser else {
            throw NSError(
                domain: "CollectionService",
                code: 403,
                userInfo: [NSLocalizedDescriptionKey: "Batas maksimal 50 koleksi tercapai."]
            )
        }
        
        // 3. Eksekusi pembuatan koleksi
        try await firestoreRepo.createCollection(collection: collection)
    }
    
    func addRecipeToCollection(collectionId: String, recipeId: String) async throws {
        try await firestoreRepo.addRecipeToCollection(collectionId: collectionId, recipeId: recipeId)
    }
}

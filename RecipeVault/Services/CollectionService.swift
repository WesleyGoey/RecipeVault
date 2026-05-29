//
//  CollectionService 2.swift
//  RecipeVault
//
//  Created by Nicholas Gerwin Mawardji on 29/05/26.
//


import Foundation
import FirebaseFirestore

// MARK: - Collection Service Implementation
final class CollectionService: CollectionServiceProtocol {
    
    // MARK: - Properties
    // Menggunakan singleton pattern untuk kemudahan akses jika tidak menggunakan dependency container
    static let shared = CollectionService(firestoreRepo: FirestoreRepository.shared)
    private let firestoreRepo: FirestoreRepositoryProtocol
    
    // Batas koleksi sesuai NFR-04
    private let maxCollectionsPerUser = 50
    
    // MARK: - Initializer (Dependency Injection)
    init(firestoreRepo: FirestoreRepositoryProtocol) {
        self.firestoreRepo = firestoreRepo
    }
    
    // MARK: - Create Operations
    
    func createCollection(collection: Collection) async throws {
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
    
    // MARK: - Update Operations
    
    func addRecipeToCollection(collectionId: String, recipeId: String) async throws {
        try await firestoreRepo.addRecipeToCollection(collectionId: collectionId, recipeId: recipeId)
    }
    
    // MARK: - Fetch Operations
    
    /// Mengambil data junction dari repository untuk mengetahui resep apa saja yang ada di koleksi ini
    func getCollectionRecipes(collectionId: String) async throws -> [CollectionRecipe] {
        return try await firestoreRepo.getCollectionRecipes(collectionId: collectionId)
    }
}

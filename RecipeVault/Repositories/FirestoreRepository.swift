//
//  FirestoreRepository.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


// MARK: - FirestoreRepository
import Foundation
import FirebaseFirestore

class FirestoreRepository: FirestoreRepositoryProtocol {
    
    // MARK: - Properties
    static let shared = FirestoreRepository()
    private let db = Firestore.firestore()
    
    // MARK: - Initializer
    private init() {}
    
    // MARK: - User Methods
    func saveUserProfile(userId: String, name: String, email: String, profilePicture: String = "") async throws {
        let userData: [String: Any] = [
            "name": name,
            "email": email,
            "profilePicture": profilePicture
        ]
        
        try await db.collection("users").document(userId).setData(userData)
    }
    
    // MARK: - Recipe Methods
    func createRecipe(recipe: Recipe) async throws {
        let ref = db.collection("recipes").document()
        try ref.setData(from: recipe)
    }
    
    // MARK: - Collection Methods
    func createCollection(collection: RecipeCollection) async throws {
        let ref = db.collection("collections").document()
        try ref.setData(from: collection)
    }
    
    func getPublicCollections() async throws -> [RecipeCollection] {
        let snapshot = try await db.collection("collections")
            .whereField("visibility", isEqualTo: Visibility.publicVisibility.rawValue)
            .getDocuments()
            
        return snapshot.documents.compactMap { try? $0.data(as: RecipeCollection.self) }
    }
    
    func getUserCollections(userId: String) async throws -> [RecipeCollection] {
        let snapshot = try await db.collection("collections")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
            
        return snapshot.documents.compactMap { try? $0.data(as: RecipeCollection.self) }
    }
    
    // MARK: - Junction Table Methods
    func addRecipeToCollection(collectionId: String, recipeId: String) async throws {
        let ref = db.collection("collection_recipes").document()
        let junction = CollectionRecipe(collectionId: collectionId, recipeId: recipeId)
        
        try ref.setData(from: junction)
    }
}
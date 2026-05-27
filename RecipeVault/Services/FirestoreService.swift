//
//  FirestoreService.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 28/05/26.
//


import Foundation
import FirebaseFirestore

class FirestoreService {
    static let shared = FirestoreService()
    let db = Firestore.firestore()
    
    // MARK: - Users
    func saveUserProfile(userId: String, name: String, email: String, profilePicture: String = "") async throws {
        let userData: [String: Any] = [
            "name": name,
            "email": email,
            "profilePicture": profilePicture
        ]
        try await db.collection("users").document(userId).setData(userData)
    }
    
    func getUserProfile(userId: String) async throws -> User {
        let snapshot = try await db.collection("users").document(userId).getDocument()
        return try snapshot.data(as: User.self)
    }
    
    // MARK: - Recipes (Personal)
    func createRecipe(recipe: Recipe) async throws {
        let ref = db.collection("recipes").document()
        try ref.setData(from: recipe)
    }
    
    // MARK: - Collections
    func createCollection(collection: RecipeCollection) async throws {
        let ref = db.collection("collections").document()
        try ref.setData(from: collection)
    }
    
    // Fetch ONLY Public Collections (For the Discovery Feed)
    func getPublicCollections() async throws -> [RecipeCollection] {
        let snapshot = try await db.collection("collections")
            .whereField("visibility", isEqualTo: Visibility.publicVisibility.rawValue)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: RecipeCollection.self) }
    }
    
    // Fetch ONLY the current user's collections (For the Bottom Sheet & Profile)
    func getUserCollections(userId: String) async throws -> [RecipeCollection] {
        let snapshot = try await db.collection("collections")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
            
        return snapshot.documents.compactMap { try? $0.data(as: RecipeCollection.self) }
    }
    // MARK: - Junction Table (Add Recipe to Collection)
    func addRecipeToCollection(collectionId: String, recipeId: String) async throws {
        let ref = db.collection("collection_recipes").document()
        let junction = CollectionRecipe(collectionId: collectionId, recipeId: recipeId)
        try ref.setData(from: junction)
    }
}

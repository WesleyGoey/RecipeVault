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
    // 1. CREATE
    func createRecipe(recipe: Recipe) async throws {
        let ref = db.collection("recipes").document()
        try ref.setData(from: recipe)
    }
    
    // 2. READ (Mengambil resep milik user yang sedang login)
    func getUserRecipes(userId: String) async throws -> [Recipe] {
        let snapshot = try await db.collection("recipes")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        // Mengubah hasil JSON dari Firebase menjadi Array of Recipe
        return snapshot.documents.compactMap { try? $0.data(as: Recipe.self) }
    }
    
    // 3. UPDATE (Mengubah data resep yang sudah ada)
    func updateRecipe(recipe: Recipe) async throws {
        guard let recipeId = recipe.id else {
            throw NSError(domain: "Firestore", code: 400, userInfo: [NSLocalizedDescriptionKey: "Recipe ID tidak ditemukan"])
        }
        let ref = db.collection("recipes").document(recipeId)
        try ref.setData(from: recipe) // setData akan menimpa data lama dengan data baru yang sudah diedit
    }
    
    // 4. DELETE (Menghapus resep berdasarkan ID)
    func deleteRecipe(recipeId: String) async throws {
        try await db.collection("recipes").document(recipeId).delete()
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

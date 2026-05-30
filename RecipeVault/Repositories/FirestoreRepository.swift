//
//  FirestoreRepository.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


//
//  FirestoreRepository.swift
//  RecipeVault
//

import Foundation
import FirebaseFirestore

class FirestoreRepository: FirestoreRepositoryProtocol {
    static let shared = FirestoreRepository()
    private let db = Firestore.firestore()
    private init() {}
    
    
    // MARK: - User Methods
    func getUserProfile(userId: String) async throws -> [String: Any]? {
        let doc = try await db.collection("users").document(userId).getDocument()
        return doc.data()
    }
    
    func saveUserProfile(userId: String, name: String, email: String, profilePicture: String = "") async throws {
        let userData: [String: Any] = ["name": name, "email": email, "profilePicture": profilePicture]
        try await db.collection("users").document(userId).setData(userData, merge: true) // 🚀 Gunakan merge agar tidak menimpa data favorit
    }
    
    // MARK: - Recipe Methods
    func createRecipe(recipe: Recipe) async throws {
        let ref = db.collection("recipes").document()
        try ref.setData(from: recipe)
    }
    func getUserRecipes(userId: String) async throws -> [Recipe] {
        let snapshot = try await db.collection("recipes").whereField("userId", isEqualTo: userId).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Recipe.self) }
    }
    func updateRecipe(recipe: Recipe) async throws {
        guard let recipeId = recipe.id else { return }
        try db.collection("recipes").document(recipeId).setData(from: recipe)
    }
    func deleteRecipe(recipeId: String) async throws {
        try await db.collection("recipes").document(recipeId).delete()
    }
    
    // MARK: - Collection Methods
    func createCollection(collection: RecipeCollection) async throws {
        let ref = db.collection("collections").document()
        var newCol = collection
        newCol.id = ref.documentID
        try ref.setData(from: newCol)
    }
    
    func getPublicCollections() async throws -> [RecipeCollection] {
        let snapshot = try await db.collection("collections").whereField("visibility", isEqualTo: "public").getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: RecipeCollection.self) }
    }
    
    func getUserCollections(userId: String) async throws -> [RecipeCollection] {
        let snapshot = try await db.collection("collections").whereField("userId", isEqualTo: userId).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: RecipeCollection.self) }
    }
    
    func getRecipeCountInCollection(collectionId: String) async throws -> Int {
        let snapshot = try await db.collection("collection_recipes")
            .whereField("collectionId", isEqualTo: collectionId)
            .getDocuments()
        return snapshot.documents.count
    }
    
    func updateCollection(collection: RecipeCollection) async throws {
        guard let colId = collection.id else { return }
        try db.collection("collections").document(colId).setData(from: collection)
    }
    func deleteCollection(collectionId: String) async throws {
        try await db.collection("collections").document(collectionId).delete()
    }
    
    // MARK: - 🌟 FAVORITES METHODS
    func toggleFavorite(userId: String, recipeId: String, isFavorite: Bool) async throws {
        let userRef = db.collection("users").document(userId)
        if isFavorite {
            // Tambahkan ke array tanpa duplikasi
            try await userRef.setData(["favoriteRecipeIds": FieldValue.arrayUnion([recipeId])], merge: true)
        } else {
            // Hapus dari array
            try await userRef.setData(["favoriteRecipeIds": FieldValue.arrayRemove([recipeId])], merge: true)
        }
    }
    
    func getFavoriteRecipeIds(userId: String) async throws -> [String] {
        let doc = try await db.collection("users").document(userId).getDocument()
        return doc.data()?["favoriteRecipeIds"] as? [String] ?? []
    }
    
    func getFavoriteRecipes(userId: String) async throws -> [Recipe] {
        let ids = try await getFavoriteRecipeIds(userId: userId)
        guard !ids.isEmpty else { return [] }
        
        var recipes: [Recipe] = []
        for id in ids {
            let doc = try await db.collection("recipes").document(id).getDocument()
            if let recipe = try? doc.data(as: Recipe.self) { recipes.append(recipe) }
        }
        return recipes
    }
    
    // MARK: - 🌟 JUNCTION TABLE (ADD TO COLLECTION)
    func addRecipeToCollection(collectionId: String, recipeId: String) async throws {
        // 🚀 Bikin ID dokumen gabungan agar tidak ada resep kembar di 1 koleksi
        let junctionId = "\(collectionId)_\(recipeId)"
        let ref = db.collection("collection_recipes").document(junctionId)
        
        let junctionData: [String: Any] = [
            "collectionId": collectionId,
            "recipeId": recipeId,
            "addedAt": FieldValue.serverTimestamp()
        ]
        try await ref.setData(junctionData) // Ini aman, kalau udah ada dia cuma menimpa (overwrite)
    }
    
    func removeRecipeFromCollection(collectionId: String, recipeId: String) async throws {
        let junctionId = "\(collectionId)_\(recipeId)"
        try await db.collection("collection_recipes").document(junctionId).delete()
    }
    
    func getRecipesInCollection(collectionId: String) async throws -> [Recipe] {
        let snapshot = try await db.collection("collection_recipes").whereField("collectionId", isEqualTo: collectionId).getDocuments()
        let recipeIds = snapshot.documents.compactMap { $0.data()["recipeId"] as? String }
        
        guard !recipeIds.isEmpty else { return [] }
        
        var recipes: [Recipe] = []
        for id in recipeIds {
            let doc = try await db.collection("recipes").document(id).getDocument()
            if let recipe = try? doc.data(as: Recipe.self) { recipes.append(recipe) }
        }
        return recipes
    }
}

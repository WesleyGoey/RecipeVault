//
//  FirestoreRepository.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation
import FirebaseFirestore

// MARK: - FirestoreRepository Class
class FirestoreRepository: FirestoreRepositoryProtocol {
    static let shared = FirestoreRepository()
    private let db = Firestore.firestore()
    
    // MARK: - Initializer
    private init() {}
    
    // MARK: - User Section
    
    // MARK: - Get User Profile
    func getUserProfile(userId: String) async throws -> [String: Any]? {
        let doc = try await db.collection("users").document(userId).getDocument()
        return doc.data()
    }
    
    // MARK: - Save User Profile
    func saveUserProfile(userId: String, name: String, email: String, profilePicture: String = "") async throws {
        let userData: [String: Any] = ["name": name, "email": email, "profilePicture": profilePicture]
        try await db.collection("users").document(userId).setData(userData, merge: true)
    }
    
    
    // MARK: - Recipe Section
    
    // MARK: - Create Recipe
    func createRecipe(recipe: Recipe) async throws {
        let db = Firestore.firestore()
        let documentId = recipe.id ?? UUID().uuidString
        let docRef = db.collection("recipes").document(documentId)
        try docRef.setData(from: recipe)
    }
    
    // MARK: - Get User Recipes
    func getUserRecipes(userId: String) async throws -> [Recipe] {
        let snapshot = try await db.collection("recipes").whereField("userId", isEqualTo: userId).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Recipe.self) }
    }
    
    // MARK: - Get Recipe By ID
    func getRecipeById(recipeId: String) async throws -> Recipe? {
        let doc = try await db.collection("recipes").document(recipeId).getDocument()
        return try? doc.data(as: Recipe.self)
    }
    
    // MARK: - Update Recipe
    func updateRecipe(recipe: Recipe) async throws {
        guard let recipeId = recipe.id else { return }
        try db.collection("recipes").document(recipeId).setData(from: recipe)
    }
    
    // MARK: - Delete Recipe
    func deleteRecipe(recipeId: String) async throws {
        try await db.collection("recipes").document(recipeId).delete()
    }
    
    // MARK: - Save Recipe If Needed
    func saveRecipeIfNeeded(recipe: Recipe) async throws {
        if let id = recipe.id, !id.isEmpty {
            try db.collection("recipes").document(id).setData(from: recipe, merge: true)
        } else {
            let ref = db.collection("recipes").document()
            var r = recipe
            r.id = ref.documentID
            try ref.setData(from: r)
        }
    }
    
    
    // MARK: - Collection Section
    
    // MARK: - Create Collection
    func createCollection(collection: RecipeCollection) async throws {
        let ref = db.collection("collections").document()
        var newCol = collection
        newCol.id = ref.documentID
        try ref.setData(from: newCol)
    }
    
    // MARK: - Get Public Collections
    func getPublicCollections() async throws -> [RecipeCollection] {
        let snapshot = try await db.collection("collections").whereField("visibility", isEqualTo: "public").getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: RecipeCollection.self) }
    }
    
    // MARK: - Get User Collections
    func getUserCollections(userId: String) async throws -> [RecipeCollection] {
        let snapshot = try await db.collection("collections").whereField("userId", isEqualTo: userId).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: RecipeCollection.self) }
    }
    
    // MARK: - Update Collection
    func updateCollection(collection: RecipeCollection) async throws {
        guard let colId = collection.id else { return }
        try db.collection("collections").document(colId).setData(from: collection)
    }
    
    // MARK: - Delete Collection
    func deleteCollection(collectionId: String) async throws {
        try await db.collection("collections").document(collectionId).delete()
    }
    
    
    // MARK: - Favorite Section
    
    // MARK: - Toggle Favorite
    func toggleFavorite(userId: String, recipeId: String, isFavorite: Bool) async throws {
        let userRef = db.collection("users").document(userId)
        if isFavorite {
            try await userRef.setData(["favoriteRecipeIds": FieldValue.arrayUnion([recipeId])], merge: true)
        } else {
            try await userRef.setData(["favoriteRecipeIds": FieldValue.arrayRemove([recipeId])], merge: true)
        }
    }
    
    // MARK: - Get Favorite IDs
    func getFavoriteRecipeIds(userId: String) async throws -> [String] {
        let doc = try await db.collection("users").document(userId).getDocument()
        return doc.data()?["favoriteRecipeIds"] as? [String] ?? []
    }
    
    // MARK: - Get Favorite Recipes
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
    
    
    // MARK: - Junction Table Section
    
    // MARK: - Add Recipe To Collection
    func addRecipeToCollection(collectionId: String, recipeId: String) async throws {
        let junctionId = "\(collectionId)_\(recipeId)"
        let ref = db.collection("collection_recipes").document(junctionId)
        
        let junctionData: [String: Any] = [
            "collectionId": collectionId,
            "recipeId": recipeId,
            "addedAt": FieldValue.serverTimestamp()
        ]
        try await ref.setData(junctionData)
    }
    
    // MARK: - Remove Recipe From Collection
    func removeRecipeFromCollection(collectionId: String, recipeId: String) async throws {
        let junctionId = "\(collectionId)_\(recipeId)"
        try await db.collection("collection_recipes").document(junctionId).delete()
    }
    
    // MARK: - Get Recipes In Collection
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
    
    // MARK: - Get Recipe Count In Collection
    func getRecipeCountInCollection(collectionId: String) async throws -> Int {
        let snapshot = try await db.collection("collection_recipes")
            .whereField("collectionId", isEqualTo: collectionId)
            .getDocuments()
        return snapshot.documents.count
    }
    
    // MARK: - Get Collection IDs For Recipe
    func getCollectionIdsForRecipe(recipeId: String) async throws -> [String] {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("collection_recipes")
            .whereField("recipeId", isEqualTo: recipeId)
            .getDocuments()
        return snapshot.documents.compactMap { $0.data()["collectionId"] as? String }
    }
}

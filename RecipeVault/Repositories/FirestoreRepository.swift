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
    
    // MARK: - Collection Methods (Di dalam FirestoreRepository.swift)
    func createCollection(collection: RecipeCollection) async throws {
        let ref = db.collection("collections").document()
        var newCol = collection
        newCol.id = ref.documentID
        
        // Gunakan encoder untuk mengizinkan Timestamp estimate seperti pada resep
        try ref.setData(from: newCol)
    }

    func getPublicCollections() async throws -> [RecipeCollection] {
        let snapshot = try await db.collection("collections")
            .whereField("visibility", isEqualTo: "public") // Pastikan string enum sesuai
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: RecipeCollection.self) }
    }

    func getUserCollections(userId: String) async throws -> [RecipeCollection] {
        let snapshot = try await db.collection("collections")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: RecipeCollection.self) }
    }

    // 🚀 TAMBAHAN: UPDATE COLLECTION
    func updateCollection(collection: RecipeCollection) async throws {
        guard let colId = collection.id else { throw NSError(domain: "Firestore", code: 400, userInfo: [NSLocalizedDescriptionKey: "Collection ID tidak ditemukan"]) }
        try db.collection("collections").document(colId).setData(from: collection)
    }

    // 🚀 TAMBAHAN: DELETE COLLECTION
    func deleteCollection(collectionId: String) async throws {
        try await db.collection("collections").document(collectionId).delete()
        // Opsional: Hapus juga data di tabel collection_recipes yang terkait dengan koleksi ini
    }

    // MARK: - Junction Table Methods
    func addRecipeToCollection(collectionId: String, recipeId: String) async throws {
        let ref = db.collection("collection_recipes").document()
        let junctionData: [String: Any] = [
            "collectionId": collectionId,
            "recipeId": recipeId,
            "addedAt": FieldValue.serverTimestamp()
        ]
        try await ref.setData(junctionData)
    }

    // 🚀 TAMBAHAN: Mengambil resep di dalam koleksi
    func getRecipesInCollection(collectionId: String) async throws -> [Recipe] {
        // 1. Cari semua recipeId di tabel relasi
        let snapshot = try await db.collection("collection_recipes")
            .whereField("collectionId", isEqualTo: collectionId)
            .getDocuments()
        
        let recipeIds = snapshot.documents.compactMap { $0.data()["recipeId"] as? String }
        
        guard !recipeIds.isEmpty else { return [] }
        
        // 2. Ambil dokumen Recipe berdasarkan ID yang ditemukan
        var recipes: [Recipe] = []
        for id in recipeIds {
            let doc = try await db.collection("recipes").document(id).getDocument()
            // 🚀 PERBAIKAN: Menggunakan parameter 'withServerTimestampBehavior' yang tepat
            if let recipe = try? doc.data(as: Recipe.self) {
                recipes.append(recipe)
            }
        }
        return recipes
    }
}

//
//  CollectionServiceProtocol.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


// MARK: - CollectionServiceProtocol
import Foundation

protocol CollectionServiceProtocol {
    // 🚀 CREATE: Menggunakan imageData opsional untuk sampul koleksi
        func createCollection(collection: RecipeCollection, imageData: Data?) async throws
        
        // 🚀 READ
        func getUserCollections(userId: String) async throws -> [RecipeCollection]
        func getRecipesInCollection(collectionId: String) async throws -> [Recipe]
        
        // 🚀 UPDATE: Menggunakan newImageData opsional untuk update sampul
        func updateCollection(collection: RecipeCollection, newImageData: Data?) async throws
        
        // 🚀 DELETE
        func deleteCollection(collectionId: String) async throws
        
        // 🚀 RELASI
        func addRecipeToCollection(collectionId: String, recipeId: String) async throws
}

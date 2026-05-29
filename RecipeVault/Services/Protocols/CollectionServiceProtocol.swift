//
//  CollectionServiceProtocol.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


// MARK: - CollectionServiceProtocol
import Foundation

protocol CollectionServiceProtocol {
    func createCollection(collection: Collection) async throws
    func addRecipeToCollection(collectionId: String, recipeId: String) async throws

    // Mengambil daftar relasi resep yang berada di dalam sebuah koleksi
        func getCollectionRecipes(collectionId: String) async throws -> [CollectionRecipe]
}

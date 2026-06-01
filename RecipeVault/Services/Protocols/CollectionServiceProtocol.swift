//
//  CollectionServiceProtocol.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//

import Foundation

// MARK: - CollectionService Protocol
protocol CollectionServiceProtocol {
    // MARK: - Collection Section
    
    // MARK: - Create Collection
    func createCollection(collection: RecipeCollection, imageData: Data?) async throws
    
    // MARK: - Get User Collections
    func getUserCollections(userId: String) async throws -> [RecipeCollection]
    
    // MARK: - Get Public Collections
    func getPublicCollections() async throws -> [RecipeCollection]
    
    // MARK: - Update Collection
    func updateCollection(collection: RecipeCollection, newImageData: Data?) async throws
    
    // MARK: - Delete Collection
    func deleteCollection(collectionId: String) async throws
    
    
    // MARK: - Recipe Section
    
    // MARK: - Get Recipes In Collection
    func getRecipesInCollection(collectionId: String) async throws -> [Recipe]
    
    // MARK: - Get Recipe Count In Collection
    func getRecipeCountInCollection(collectionId: String) async throws -> Int
    
    // MARK: - Add Recipe To Collection
    func addRecipeToCollection(collectionId: String, recipeId: String) async throws
    
    // MARK: - Remove Recipe From Collection
    func removeRecipeFromCollection(collectionId: String, recipeId: String) async throws
    
    // MARK: - Get Collection IDs For Recipe
    func getCollectionIdsForRecipe(recipeId: String) async throws -> [String]
}

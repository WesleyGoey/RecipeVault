//
//  CollectionServiceProtocol.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


// MARK: - CollectionServiceProtocol
import Foundation

protocol CollectionServiceProtocol {
    func createCollection(collection: RecipeCollection, imageData: Data?) async throws
    func getUserCollections(userId: String) async throws -> [RecipeCollection]
    func getPublicCollections() async throws -> [RecipeCollection]
    func getRecipesInCollection(collectionId: String) async throws -> [Recipe]
    func getRecipeCountInCollection(collectionId: String) async throws -> Int
    func updateCollection(collection: RecipeCollection, newImageData: Data?) async throws
    func deleteCollection(collectionId: String) async throws
    
    func addRecipeToCollection(collectionId: String, recipeId: String) async throws
    func removeRecipeFromCollection(collectionId: String, recipeId: String) async throws
    func getCollectionIdsForRecipe(recipeId: String) async throws -> [String]
}

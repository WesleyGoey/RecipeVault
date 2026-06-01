//
//  FirestoreRepositoryProtocol.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation

protocol FirestoreRepositoryProtocol {
    func getUserProfile(userId: String) async throws -> [String: Any]?
    func saveUserProfile(userId: String, name: String, email: String, profilePicture: String) async throws

    func createRecipe(recipe: Recipe) async throws
    func getUserRecipes(userId: String) async throws -> [Recipe]
    func updateRecipe(recipe: Recipe) async throws
    func deleteRecipe(recipeId: String) async throws

    func getRecipeById(recipeId: String) async throws -> Recipe?
    func saveRecipeIfNeeded(recipe: Recipe) async throws
    func createCollection(collection: RecipeCollection) async throws
    func getPublicCollections() async throws -> [RecipeCollection]
    func getUserCollections(userId: String) async throws -> [RecipeCollection]
    func getRecipeCountInCollection(collectionId: String) async throws -> Int
    func updateCollection(collection: RecipeCollection) async throws   
    func deleteCollection(collectionId: String) async throws
    func getCollectionIdsForRecipe(recipeId: String) async throws -> [String]

    func toggleFavorite(userId: String, recipeId: String, isFavorite: Bool) async throws
    func getFavoriteRecipeIds(userId: String) async throws -> [String]
    func getFavoriteRecipes(userId: String) async throws -> [Recipe]

    func addRecipeToCollection(collectionId: String, recipeId: String) async throws
    func removeRecipeFromCollection(collectionId: String, recipeId: String) async throws
    func getRecipesInCollection(collectionId: String) async throws -> [Recipe]
}

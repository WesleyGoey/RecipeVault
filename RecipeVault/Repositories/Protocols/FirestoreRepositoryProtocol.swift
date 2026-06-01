//
//  FirestoreRepositoryProtocol.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation
// ... existing contents ...

protocol FirestoreRepositoryProtocol {
    func getUserProfile(userId: String) async throws -> [String: Any]?
    func saveUserProfile(userId: String, name: String, email: String, profilePicture: String) async throws

    // 🚀 FULL CRUD RECIPE
    func createRecipe(recipe: Recipe) async throws
    func getUserRecipes(userId: String) async throws -> [Recipe] // READ
    func updateRecipe(recipe: Recipe) async throws               // UPDATE
    func deleteRecipe(recipeId: String) async throws             // DELETE

    // NEW: allow service to query and save single recipe by id (used for mirroring TheMealDB)
    func getRecipeById(recipeId: String) async throws -> Recipe?
    func saveRecipeIfNeeded(recipe: Recipe) async throws
    func createCollection(collection: RecipeCollection) async throws
    func getPublicCollections() async throws -> [RecipeCollection]
    func getUserCollections(userId: String) async throws -> [RecipeCollection]
    func getRecipeCountInCollection(collectionId: String) async throws -> Int
    func updateCollection(collection: RecipeCollection) async throws   
    func deleteCollection(collectionId: String) async throws

    /// 🚀 FAVORITES
    func toggleFavorite(userId: String, recipeId: String, isFavorite: Bool) async throws
    func getFavoriteRecipeIds(userId: String) async throws -> [String]
    func getFavoriteRecipes(userId: String) async throws -> [Recipe]

    // 🚀 RELASI (Add to Collection)
    func addRecipeToCollection(collectionId: String, recipeId: String) async throws
    func removeRecipeFromCollection(collectionId: String, recipeId: String) async throws
    func getRecipesInCollection(collectionId: String) async throws -> [Recipe]
}

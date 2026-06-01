//
//  FirestoreRepositoryProtocol.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation

import Foundation

// MARK: - FirestoreRepository Protocol
protocol FirestoreRepositoryProtocol {

    // MARK: - User Section
    
    // MARK: - Get User Profile
    func getUserProfile(userId: String) async throws -> [String: Any]?
    
    // MARK: - Save User Profile
    func saveUserProfile(userId: String, name: String, email: String, profilePicture: String) async throws


    // MARK: - Recipe Section
    
    // MARK: - Create Recipe
    func createRecipe(recipe: Recipe) async throws
    
    // MARK: - Get User Recipes
    func getUserRecipes(userId: String) async throws -> [Recipe]
    
    // MARK: - Update Recipe
    func updateRecipe(recipe: Recipe) async throws
    
    // MARK: - Delete Recipe
    func deleteRecipe(recipeId: String) async throws
    
    // MARK: - Get Recipe By ID
    func getRecipeById(recipeId: String) async throws -> Recipe?
    
    // MARK: - Save Recipe If Needed
    func saveRecipeIfNeeded(recipe: Recipe) async throws


    // MARK: - Collection Section
    
    // MARK: - Create Collection
    func createCollection(collection: RecipeCollection) async throws
    
    // MARK: - Get Public Collections
    func getPublicCollections() async throws -> [RecipeCollection]
    
    // MARK: - Get User Collections
    func getUserCollections(userId: String) async throws -> [RecipeCollection]
    
    // MARK: - Update Collection
    func updateCollection(collection: RecipeCollection) async throws
    
    // MARK: - Delete Collection
    func deleteCollection(collectionId: String) async throws


    // MARK: - Favorite Section
    
    // MARK: - Toggle Favorite
    func toggleFavorite(userId: String, recipeId: String, isFavorite: Bool) async throws
    
    // MARK: - Get Favorite Recipe IDs
    func getFavoriteRecipeIds(userId: String) async throws -> [String]
    
    // MARK: - Get Favorite Recipes
    func getFavoriteRecipes(userId: String) async throws -> [Recipe]


    // MARK: - Junction Table Section
    
    // MARK: - Add Recipe To Collection
    func addRecipeToCollection(collectionId: String, recipeId: String) async throws
    
    // MARK: - Remove Recipe From Collection
    func removeRecipeFromCollection(collectionId: String, recipeId: String) async throws
    
    // MARK: - Get Recipes In Collection
    func getRecipesInCollection(collectionId: String) async throws -> [Recipe]
    
    // MARK: - Get Recipe Count In Collection
    func getRecipeCountInCollection(collectionId: String) async throws -> Int
    
    // MARK: - Get Collection IDs For Recipe
    func getCollectionIdsForRecipe(recipeId: String) async throws -> [String]
}

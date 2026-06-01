//
//  RecipeServiceProtocol.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation

// MARK: - RecipeService Protocol
protocol RecipeServiceProtocol {
    // MARK: - Recipe Section

    // MARK: - Create Recipe
    func createRecipe(recipe: Recipe, imageData: Data?) async throws

    // MARK: - Get User Recipes
    func getUserRecipes(userId: String) async throws -> [Recipe]

    // MARK: - Update Recipe
    func updateRecipe(recipe: Recipe, newImageData: Data?) async throws

    // MARK: - Delete Recipe
    func deleteRecipe(recipeId: String) async throws


    // MARK: - Favorite Section

    // MARK: - Toggle Favorite
    func toggleFavorite(userId: String, recipeId: String, isFavorite: Bool) async throws

    // MARK: - Get Favorite Recipe IDs
    func getFavoriteRecipeIds(userId: String) async throws -> [String]

    // MARK: - Get Favorite Recipes
    func getFavoriteRecipes(userId: String) async throws -> [Recipe]
}

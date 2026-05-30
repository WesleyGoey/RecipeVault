//
//  RecipeServiceProtocol.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


// MARK: - RecipeServiceProtocol
import Foundation

protocol RecipeServiceProtocol {
    func createRecipeWithImage(recipe: Recipe, imageData: Data?) async throws
    func getUserRecipes(userId: String) async throws -> [Recipe]
    func updateRecipe(recipe: Recipe, newImageData: Data?) async throws
    func deleteRecipe(recipeId: String) async throws
}

//
//  RecipeService.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation
import UIKit

// MARK: - RecipeService Class
class RecipeService: RecipeServiceProtocol {
    static let shared = RecipeService(firestoreRepo: FirestoreRepository.shared)
    private let firestoreRepo: FirestoreRepositoryProtocol

    // MARK: - Initializer
    init(firestoreRepo: FirestoreRepositoryProtocol) {
        self.firestoreRepo = firestoreRepo
    }

    // MARK: - Recipe Section

    // MARK: - Create Recipe
    func createRecipe(recipe: Recipe, imageData: Data?) async throws {
        var newRecipe = recipe
        
        if let data = imageData, let uiImage = UIImage(data: data) {
            newRecipe.recipeImage = Base64Helper.encode(uiImage) ?? ""
        }
        
        try await firestoreRepo.createRecipe(recipe: newRecipe)
    }

    // MARK: - Get User Recipes
    func getUserRecipes(userId: String) async throws -> [Recipe] {
        return try await firestoreRepo.getUserRecipes(userId: userId)
    }

    // MARK: - Update Recipe
    func updateRecipe(recipe: Recipe, newImageData: Data?) async throws {
        var updatedRecipe = recipe
        
        if let data = newImageData, let uiImage = UIImage(data: data) {
            updatedRecipe.recipeImage = Base64Helper.encode(uiImage) ?? ""
        }
        
        try await firestoreRepo.updateRecipe(recipe: updatedRecipe)
    }

    // MARK: - Delete Recipe
    func deleteRecipe(recipeId: String) async throws {
        try await firestoreRepo.deleteRecipe(recipeId: recipeId)
    }

    
    // MARK: - Favorite Section

    // MARK: - Toggle Favorite
    func toggleFavorite(userId: String, recipeId: String, isFavorite: Bool) async throws {
        try await firestoreRepo.toggleFavorite(userId: userId, recipeId: recipeId, isFavorite: isFavorite)
    }

    // MARK: - Get Favorite Recipe IDs
    func getFavoriteRecipeIds(userId: String) async throws -> [String] {
        return try await firestoreRepo.getFavoriteRecipeIds(userId: userId)
    }

    // MARK: - Get Favorite Recipes
    func getFavoriteRecipes(userId: String) async throws -> [Recipe] {
        return try await firestoreRepo.getFavoriteRecipes(userId: userId)
    }
}

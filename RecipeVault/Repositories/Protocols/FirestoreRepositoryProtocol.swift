//
//  FirestoreRepositoryProtocol.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation

protocol FirestoreRepositoryProtocol {
    func saveUserProfile(userId: String, name: String, email: String, profilePicture: String) async throws
    
    // 🚀 FULL CRUD RECIPE
    func createRecipe(recipe: Recipe) async throws
    func getUserRecipes(userId: String) async throws -> [Recipe] // READ
    func updateRecipe(recipe: Recipe) async throws               // UPDATE
    func deleteRecipe(recipeId: String) async throws             // DELETE
    
    func createCollection(collection: RecipeCollection) async throws
    func getPublicCollections() async throws -> [RecipeCollection]
    func getUserCollections(userId: String) async throws -> [RecipeCollection]
    func updateCollection(collection: RecipeCollection) async throws   // 🚀 Baru
    func deleteCollection(collectionId: String) async throws           // 🚀 Baru
    
    // MARK: - Junction Table Methods
    func addRecipeToCollection(collectionId: String, recipeId: String) async throws
    func getRecipesInCollection(collectionId: String) async throws -> [Recipe] // 🚀 Baru
}

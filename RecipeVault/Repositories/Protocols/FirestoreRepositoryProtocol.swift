//
//  FirestoreRepositoryProtocol.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


// MARK: - FirestoreRepositoryProtocol
import Foundation

protocol FirestoreRepositoryProtocol {
    func saveUserProfile(userId: String, name: String, email: String, profilePicture: String) async throws
    func createRecipe(recipe: Recipe) async throws
    func createCollection(collection: RecipeCollection) async throws
    func getPublicCollections() async throws -> [RecipeCollection]
    func getUserCollections(userId: String) async throws -> [RecipeCollection]
    func addRecipeToCollection(collectionId: String, recipeId: String) async throws
}
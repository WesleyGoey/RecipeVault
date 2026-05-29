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
    func createCollection(collection: Collection) async throws
    func getPublicCollections() async throws -> [Collection]
    func getUserCollections(userId: String) async throws -> [Collection]
    func addRecipeToCollection(collectionId: String, recipeId: String) async throws
}

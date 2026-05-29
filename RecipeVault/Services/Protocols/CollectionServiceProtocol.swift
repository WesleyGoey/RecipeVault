//
//  CollectionServiceProtocol.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


// MARK: - CollectionServiceProtocol
import Foundation

protocol CollectionServiceProtocol {
    func createCollection(collection: RecipeCollection) async throws
    func addRecipeToCollection(collectionId: String, recipeId: String) async throws
}

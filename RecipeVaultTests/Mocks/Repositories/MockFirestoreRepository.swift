//
//  MockFirestoreRepository.swift
//  RecipeVault
//
//  Created by Wesley Goey on 29/05/26.
//


// MARK: - MockFirestoreRepository
import Foundation
@testable import RecipeVault

class MockFirestoreRepository: FirestoreRepositoryProtocol {
    
    // MARK: - Test Control Properties
    var mockedUserCollections: [RecipeCollection] = []
    var mockedPublicCollections: [RecipeCollection] = []
    var shouldThrowError = false
    
    // MARK: - Method Call Trackers
    var isSaveUserProfileCalled = false
    var isCreateRecipeCalled = false
    var isCreateCollectionCalled = false
    var isGetPublicCollectionsCalled = false
    var isGetUserCollectionsCalled = false
    var isAddRecipeToCollectionCalled = false
    
    // MARK: - Protocol Methods
    func saveUserProfile(userId: String, name: String, email: String, profilePicture: String) async throws {
        isSaveUserProfileCalled = true
        if shouldThrowError { throw NSError(domain: "FirestoreError", code: 500, userInfo: nil) }
    }
    
    func createRecipe(recipe: Recipe) async throws {
        isCreateRecipeCalled = true
        if shouldThrowError { throw NSError(domain: "FirestoreError", code: 500, userInfo: nil) }
    }
    
    func createCollection(collection: RecipeCollection) async throws {
        isCreateCollectionCalled = true
        if shouldThrowError { throw NSError(domain: "FirestoreError", code: 500, userInfo: nil) }
    }
    
    func getPublicCollections() async throws -> [RecipeCollection] {
        isGetPublicCollectionsCalled = true
        if shouldThrowError { throw NSError(domain: "FirestoreError", code: 500, userInfo: nil) }
        return mockedPublicCollections
    }
    
    func getUserCollections(userId: String) async throws -> [RecipeCollection] {
        isGetUserCollectionsCalled = true
        if shouldThrowError { throw NSError(domain: "FirestoreError", code: 500, userInfo: nil) }
        return mockedUserCollections
    }
    
    func addRecipeToCollection(collectionId: String, recipeId: String) async throws {
        isAddRecipeToCollectionCalled = true
        if shouldThrowError { throw NSError(domain: "FirestoreError", code: 500, userInfo: nil) }
    }
}

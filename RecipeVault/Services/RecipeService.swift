//
//  RecipeService.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//

import Foundation
import UIKit

class RecipeService: RecipeServiceProtocol {
    
    // 🚀 EFISIENSI: Buang storageRepo karena kita hanya pakai Firestore untuk Base64
    static let shared = RecipeService(firestoreRepo: FirestoreRepository.shared)
    
    private let firestoreRepo: FirestoreRepositoryProtocol
    
    init(firestoreRepo: FirestoreRepositoryProtocol) {
        self.firestoreRepo = firestoreRepo
    }
    
    // MARK: - 1. CREATE
    func createRecipe(recipe: Recipe, imageData: Data?) async throws {
        var newRecipe = recipe
        
        // Menggunakan Helper untuk Kompresi & Resize
        if let data = imageData, let uiImage = UIImage(data: data) {
            newRecipe.recipeImage = Base64Helper.encode(uiImage) ?? ""
        }
        
        try await firestoreRepo.createRecipe(recipe: newRecipe)
    }
    
    // MARK: - 2. READ
    func getUserRecipes(userId: String) async throws -> [Recipe] {
        return try await firestoreRepo.getUserRecipes(userId: userId)
    }
    
    // MARK: - 3. UPDATE
    func updateRecipe(recipe: Recipe, newImageData: Data?) async throws {
        var updatedRecipe = recipe
        
        // Menggunakan Helper untuk Kompresi & Resize gambar baru
        if let data = newImageData, let uiImage = UIImage(data: data) {
            updatedRecipe.recipeImage = Base64Helper.encode(uiImage) ?? ""
        }
        
        try await firestoreRepo.updateRecipe(recipe: updatedRecipe)
    }
    
    // MARK: - 4. DELETE
    func deleteRecipe(recipeId: String) async throws {
        try await firestoreRepo.deleteRecipe(recipeId: recipeId)
    }
    
    // MARK: - FAVORITES
    func toggleFavorite(userId: String, recipeId: String, isFavorite: Bool) async throws {
        try await firestoreRepo.toggleFavorite(userId: userId, recipeId: recipeId, isFavorite: isFavorite)
    }
    
    func getFavoriteRecipeIds(userId: String) async throws -> [String] {
        return try await firestoreRepo.getFavoriteRecipeIds(userId: userId)
    }
    
    func getFavoriteRecipes(userId: String) async throws -> [Recipe] {
        return try await firestoreRepo.getFavoriteRecipes(userId: userId)
    }
}

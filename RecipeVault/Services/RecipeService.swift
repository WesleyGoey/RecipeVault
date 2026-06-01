//
//  RecipeService.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//

import Foundation
import UIKit // 🚀 Wajib import UIKit untuk menangani UIImage

// MARK: - RecipeService
class RecipeService: RecipeServiceProtocol {
    
    // 🚀 HAPUS storageRepo, kita hanya pakai Firestore
    static let shared = RecipeService(
        firestoreRepo: FirestoreRepository.shared
    )
    
    private let firestoreRepo: FirestoreRepositoryProtocol
    
    // MARK: - Initializer (Dependency Injection)
    init(firestoreRepo: FirestoreRepositoryProtocol) {
        self.firestoreRepo = firestoreRepo
    }
    
    // MARK: - Methods required by RecipeServiceProtocol
    
    // 1. CREATE
    func createRecipe(recipe: Recipe, imageData: Data?) async throws {
        var newRecipe = recipe
        
        // 🚀 UBAH GAMBAR JADI BASE64 TEXT
        if let data = imageData {
            // Karena dari UI kamu mengirim `rawImageData` (kualitas 1.0),
            // kita langsung ubah saja data tersebut jadi String Base64.
            newRecipe.recipeImage = data.base64EncodedString()
        } else {
            newRecipe.recipeImage = ""
        }
        
        try await firestoreRepo.createRecipe(recipe: newRecipe)
    }
    
    // 2. READ USER RECIPES
    func getUserRecipes(userId: String) async throws -> [Recipe] {
        return try await firestoreRepo.getUserRecipes(userId: userId)
    }
    
    // 3. UPDATE
    func updateRecipe(recipe: Recipe, newImageData: Data?) async throws {
        var updatedRecipe = recipe
        
        // 🚀 UBAH GAMBAR BARU JADI BASE64 TEXT (Jika user mengganti gambar)
        if let data = newImageData {
            updatedRecipe.recipeImage = data.base64EncodedString()
        }
        
        try await firestoreRepo.updateRecipe(recipe: updatedRecipe)
    }
    
    // 4. DELETE
    func deleteRecipe(recipeId: String) async throws {
        try await firestoreRepo.deleteRecipe(recipeId: recipeId)
    }
    
    // MARK: - 🌟 FAVORITES (Dengan TheMealDB Mirroring)
    func toggleFavorite(userId: String, recipeId: String, isFavorite: Bool) async throws {
        // If adding to favorites, ensure recipe exists in Firestore (mirror from TheMealDB if needed)
        if isFavorite {
            do {
                if try await firestoreRepo.getRecipeById(recipeId: recipeId) == nil {
                    // No recipe in Firestore — try to fetch from TheMealDB lookup endpoint
                    print("[RecipeService] recipe \(recipeId) not found in Firestore, trying TheMealDB lookup...")
                    if let url = URL(string: "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(recipeId)") {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let meals = json["meals"] as? [[String: Any]],
                           let first = meals.first {
                            
                            let title = first["strMeal"] as? String ?? "Unknown"
                            let category = first["strCategory"] as? String ?? ""
                            let area = first["strArea"] as? String ?? ""
                            let instructions = first["strInstructions"] as? String ?? ""
                            let image = first["strMealThumb"] as? String ?? ""
                            let mealId = first["idMeal"] as? String ?? recipeId
                            
                            // Parse dynamic ingredient fields (strIngredient1..20 + strMeasure1..20)
                            var parsedIngredients: [String] = []
                            for i in 1...20 {
                                let ingKey = "strIngredient\(i)"
                                let measKey = "strMeasure\(i)"
                                if let ing = first[ingKey] as? String,
                                   !ing.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    let measure = (first[measKey] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                                    let combined = measure.isEmpty ? ing.trimmingCharacters(in: .whitespacesAndNewlines) : "\(measure) \(ing.trimmingCharacters(in: .whitespacesAndNewlines))"
                                    parsedIngredients.append(combined)
                                }
                            }
                            
                            // Steps: split instructions by newlines as a simple heuristic
                            let parsedSteps = instructions
                                .components(separatedBy: .newlines)
                                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                                .filter { !$0.isEmpty }
                            
                            var newRecipe = Recipe(
                                userId: "themealdb",
                                title: title,
                                description: instructions.isEmpty ? "A traditional \(area) dish." : instructions,
                                ingredients: parsedIngredients,
                                steps: parsedSteps.isEmpty ? [instructions] : parsedSteps,
                                category: category,
                                recipeImage: image // 🚀 Biarkan berupa URL TheMealDB
                            )
                            newRecipe.id = mealId
                            newRecipe.createdAt = Date()
                            
                            try await firestoreRepo.saveRecipeIfNeeded(recipe: newRecipe)
                            print("[RecipeService] mirrored TheMealDB recipe \(mealId) into Firestore")
                        } else {
                            print("[RecipeService] TheMealDB lookup returned no meals for id \(recipeId)")
                        }
                    } else {
                        print("[RecipeService] invalid TheMealDB lookup URL for id \(recipeId)")
                    }
                } else {
                    print("[RecipeService] recipe \(recipeId) already exists in Firestore")
                }
            } catch {
                print("[RecipeService]: warning failed to mirror external recipe before favoriting: \(error)")
            }
        }
        
        // Finally toggle favorite in user's favorites subcollection
        try await firestoreRepo.toggleFavorite(userId: userId, recipeId: recipeId, isFavorite: isFavorite)
    }
    
    func getFavoriteRecipeIds(userId: String) async throws -> [String] {
        return try await firestoreRepo.getFavoriteRecipeIds(userId: userId)
    }
    
    func getFavoriteRecipes(userId: String) async throws -> [Recipe] {
        return try await firestoreRepo.getFavoriteRecipes(userId: userId)
    }
}

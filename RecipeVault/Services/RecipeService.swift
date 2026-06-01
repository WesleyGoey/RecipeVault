//
//  RecipeService.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//
import Foundation

// MARK: - RecipeService
class RecipeService: RecipeServiceProtocol {
    
    // MARK: - Properties
    static let shared = RecipeService(
        firestoreRepo: FirestoreRepository.shared,
        storageRepo: CloudStorageRepository.shared
    )
    
    private let firestoreRepo: FirestoreRepositoryProtocol
    private let storageRepo: CloudStorageRepositoryProtocol
    
    // MARK: - Initializer (Dependency Injection)
    init(firestoreRepo: FirestoreRepositoryProtocol, storageRepo: CloudStorageRepositoryProtocol) {
        self.firestoreRepo = firestoreRepo
        self.storageRepo = storageRepo
    }
    
    // MARK: - Business Logic (NFR-03)
    private func validateSize(image: Data, maxMB: Int = 5) -> Bool {
        let sizeInMB = Double(image.count) / (1024.0 * 1024.0)
        return sizeInMB <= Double(maxMB)
    }
    
    // MARK: - Methods required by RecipeServiceProtocol
    
    // Create (with optional image)
    func createRecipe(recipe: Recipe, imageData: Data?) async throws {
        if let data = imageData {
            guard validateSize(image: data) else {
                throw NSError(domain: "RecipeService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Ukuran gambar melebihi 5 MB."])
            }
            let imageURL = try await storageRepo.uploadImage(image: data, path: "recipe_images")
            var newRecipe = recipe
            newRecipe.recipeImage = imageURL
            try await firestoreRepo.createRecipe(recipe: newRecipe)
        } else {
            try await firestoreRepo.createRecipe(recipe: recipe)
        }
    }
    
    // Read user recipes
    func getUserRecipes(userId: String) async throws -> [Recipe] {
        return try await firestoreRepo.getUserRecipes(userId: userId)
    }
    
    // Update (with optional new image)
    func updateRecipe(recipe: Recipe, newImageData: Data?) async throws {
        var updatedRecipe = recipe
        if let data = newImageData {
            guard validateSize(image: data) else {
                throw NSError(domain: "RecipeService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Ukuran gambar melebihi 5 MB."])
            }
            let imageURL = try await storageRepo.uploadImage(image: data, path: "recipe_images")
            updatedRecipe.recipeImage = imageURL
        }
        try await firestoreRepo.updateRecipe(recipe: updatedRecipe)
    }
    
    // Delete
    func deleteRecipe(recipeId: String) async throws {
        try await firestoreRepo.deleteRecipe(recipeId: recipeId)
    }
    
    // MARK: - Favorites
    // Enhanced: If the recipe being favorited is not present in Firestore, attempt to
    // fetch it from TheMealDB API and save it to Firestore before toggling favorite.
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
                                recipeImage: image
                            )
                            // Assign the MealDB id so Firestore doc id can be set
                            newRecipe.id = mealId
                            // Optionally set createdAt to now; Firestore @ServerTimestamp will handle if nil
                            newRecipe.createdAt = Date()
                            
                            // Save to Firestore only if needed (repo has helper)
                            try await firestoreRepo.saveRecipeIfNeeded(recipe: newRecipe)
                            print("[RecipeService] mirrored TheMealDB recipe \(mealId) into Firestore")
                        } else {
                            print("[RecipeService] TheMealDB lookup returned no meals for id \(recipeId)")
                        }
                    } else {
                        print("[RecipeService] invalid TheMealDB lookup URL for id \(recipeId)")
                    }
                } else {
                    // Recipe already exists in Firestore; nothing to do
                    print("[RecipeService] recipe \(recipeId) already exists in Firestore")
                }
            } catch {
                // Non-fatal: we still attempt to toggle favorite. Log the issue.
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

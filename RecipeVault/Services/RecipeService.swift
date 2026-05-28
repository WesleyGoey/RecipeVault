//
//  RecipeService.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


// MARK: - RecipeService
import Foundation

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
    
    // MARK: - Methods
    func createRecipeWithImage(recipe: Recipe, imageData: Data) async throws {
        // Validasi Atribut Baru sebelum menyentuh database
        
        guard validateSize(image: imageData) else {
            throw NSError(domain: "RecipeService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Ukuran gambar melebihi 5 MB."])
        }
        
        let imageURL = try await storageRepo.uploadImage(image: imageData, path: "recipe_images")
        
        var newRecipe = recipe
        newRecipe.recipeImage = imageURL
        
        try await firestoreRepo.createRecipe(recipe: newRecipe)
    }
}

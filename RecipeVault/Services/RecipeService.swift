//
//  RecipeService.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


// MARK: - RecipeService
import Foundation

class RecipeService: RecipeServiceProtocol {
    
    static let shared = RecipeService(
        firestoreRepo: FirestoreRepository.shared,
        storageRepo: CloudStorageRepository.shared
    )
    
    private let firestoreRepo: FirestoreRepositoryProtocol
    private let storageRepo: CloudStorageRepositoryProtocol
    
    init(firestoreRepo: FirestoreRepositoryProtocol, storageRepo: CloudStorageRepositoryProtocol) {
        self.firestoreRepo = firestoreRepo
        self.storageRepo = storageRepo
    }
    
    private func validateSize(image: Data, maxMB: Int = 5) -> Bool {
        let sizeInMB = Double(image.count) / (1024.0 * 1024.0)
        return sizeInMB <= Double(maxMB)
    }
    
    // MARK: - Methods (🚀 REVISI FULL CRUD)
    
    // 1. CREATE
    func createRecipeWithImage(recipe: Recipe, imageData: Data?) async throws {
        var newRecipe = recipe
        
        // Jika ada gambar, upload dulu
        if let data = imageData {
            guard validateSize(image: data) else {
                throw NSError(domain: "RecipeService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Ukuran gambar melebihi 5 MB."])
            }
            let imageURL = try await storageRepo.uploadImage(image: data, path: "recipe_images")
            newRecipe.recipeImage = imageURL
        }
        
        try await firestoreRepo.createRecipe(recipe: newRecipe)
    }
    
    // 2. READ
    func getUserRecipes(userId: String) async throws -> [Recipe] {
        return try await firestoreRepo.getUserRecipes(userId: userId)
    }
    
    // 3. UPDATE
    func updateRecipe(recipe: Recipe, newImageData: Data?) async throws {
        var updatedRecipe = recipe
        
        // Cek apakah user mengganti foto saat edit
        if let data = newImageData {
            guard validateSize(image: data) else {
                throw NSError(domain: "RecipeService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Ukuran gambar melebihi 5 MB."])
            }
            // Upload gambar baru dan timpa URL lama
            let imageURL = try await storageRepo.uploadImage(image: data, path: "recipe_images")
            updatedRecipe.recipeImage = imageURL
        }
        
        // Simpan perubahan ke Firestore
        try await firestoreRepo.updateRecipe(recipe: updatedRecipe)
    }
    
    // 4. DELETE
    func deleteRecipe(recipeId: String) async throws {
        // Hapus dokumen resep di database
        try await firestoreRepo.deleteRecipe(recipeId: recipeId)
        
        // (Opsional) Di masa depan, kamu bisa memanggil CloudStorageRepository di sini
        // untuk ikut menghapus file gambarnya agar Storage Firebase tidak cepat penuh.
    }
}

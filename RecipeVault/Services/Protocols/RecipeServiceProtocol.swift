//
//  RecipeServiceProtocol.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


// MARK: - RecipeServiceProtocol
import Foundation

protocol RecipeServiceProtocol {
    func createRecipeWithImage(recipe: Recipe, imageData: Data) async throws
    
    // Mengambil detail dari banyak resep sekaligus berdasarkan daftar ID
        func getRecipes(byIds ids: [String]) async throws -> [Recipe]
}

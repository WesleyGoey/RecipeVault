//
//  TheMealDBRepositoryProtocol.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


// MARK: - TheMealDBRepositoryProtocol
import Foundation

protocol TheMealDBRepositoryProtocol {
    func searchMeals(query: String) async throws -> [MealDBRecipe]
}
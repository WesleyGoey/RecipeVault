//
//  TheMealDBServiceProtocol.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


// MARK: - TheMealDBServiceProtocol
import Foundation

protocol TheMealDBServiceProtocol {
    func searchMeals(query: String) async throws -> [MealDBRecipe]
}
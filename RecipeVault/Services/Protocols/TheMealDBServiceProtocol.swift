//
//  TheMealDBServiceProtocol.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation

// MARK: - TheMealDBService Protocol
protocol TheMealDBServiceProtocol {
    
    // MARK: - Search Meals
    func searchMeals(query: String) async throws -> [MealDBRecipe]
}

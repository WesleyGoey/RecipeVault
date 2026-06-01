//
//  TheMealDBRepositoryProtocol.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation

// MARK: - TheMealDBRepository Protocol
protocol TheMealDBRepositoryProtocol {
    // MARK: - Search Meals From API
    func searchMeals(query: String) async throws -> [MealDBRecipe]
}

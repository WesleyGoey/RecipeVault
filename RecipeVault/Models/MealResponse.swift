//
//  MealResponse.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 27/05/26.
//


import Foundation

// MARK: - MealResponse Model
struct MealResponse: Codable {
    let meals: [MealDBRecipe]?
}

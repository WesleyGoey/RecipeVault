//
//  MealDBRecipe.swift
//  RecipeVault
//
//  Created by Wesley Goey on 01/06/26.
//


import Foundation

// MARK: - MealDBRecipe Model
struct MealDBRecipe: Codable, Identifiable {
    let idMeal: String
    let strMeal: String
    let strCategory: String?
    let strArea: String?
    let strInstructions: String?
    let strMealThumb: String?
    
    var id: String { idMeal }
}

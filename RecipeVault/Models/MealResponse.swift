//
//  MealResponse.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 27/05/26.
//


import Foundation

struct MealResponse: Codable {
    let meals: [MealDBRecipe]?
}

struct MealDBRecipe: Codable, Identifiable {
    let idMeal: String
    let strMeal: String
    let strCategory: String?
    let strArea: String?
    let strInstructions: String?
    let strMealThumb: String?
    
    var id: String { idMeal }
}

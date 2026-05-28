//
//  MemoryCacheServiceProtocol.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


// MARK: - MemoryCacheServiceProtocol
import Foundation

protocol MemoryCacheServiceProtocol {
    func set(query: String, result: [MealDBRecipe])
    func get(query: String) -> [MealDBRecipe]?
    func clearAll()
}
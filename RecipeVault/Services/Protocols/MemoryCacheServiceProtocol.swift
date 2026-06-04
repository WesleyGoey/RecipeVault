//
//  MemoryCacheServiceProtocol.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation

// MARK: - MemoryCacheService Protocol
protocol MemoryCacheServiceProtocol {
    // MARK: - Set Cache
    func set(query: String, result: [MealDBRecipe])
    
    // MARK: - Get Cache
    func get(query: String) -> [MealDBRecipe]?
    
    // MARK: - Clear Cache
    func clearAll()
}

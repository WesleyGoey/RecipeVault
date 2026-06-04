//
//  MemoryCacheService.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 28/05/26.
//

import Foundation

// MARK: - MemoryCacheService Class
class MemoryCacheService: MemoryCacheServiceProtocol {
    static let shared = MemoryCacheService()
    private var cache: [String: [MealDBRecipe]] = [:]
    
    // MARK: - Initializer
    private init() {}
    
    // MARK: - Set Cache
    func set(query: String, result: [MealDBRecipe]) {
        cache[query.lowercased()] = result
    }
    
    // MARK: - Get Cache
    func get(query: String) -> [MealDBRecipe]? {
        return cache[query.lowercased()]
    }
    
    // MARK: - Clear Cache
    func clearAll() {
        cache.removeAll()
    }
}

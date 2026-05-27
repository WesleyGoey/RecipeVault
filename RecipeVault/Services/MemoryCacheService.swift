//
//  MemoryCacheService.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 28/05/26.
//


import Foundation

class MemoryCacheService {
    static let shared = MemoryCacheService()
    
    // A simple dictionary to hold data in RAM while the app is alive
    private var cache: [String: [MealDBRecipe]] = [:]
    
    func set(query: String, result: [MealDBRecipe]) {
        cache[query.lowercased()] = result
    }
    
    func get(query: String) -> [MealDBRecipe]? {
        return cache[query.lowercased()]
    }
    
    func clearAll() {
        cache.removeAll()
    }
}
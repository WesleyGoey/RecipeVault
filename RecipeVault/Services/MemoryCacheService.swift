//
//  MemoryCacheService.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 28/05/26.
//

// MARK: - MemoryCacheService
import Foundation

class MemoryCacheService: MemoryCacheServiceProtocol {
    
    // MARK: - Properties
    static let shared = MemoryCacheService()
    
    // Dictionary untuk menyimpan data di RAM selama aplikasi hidup
    private var cache: [String: [MealDBRecipe]] = [:]
    
    // MARK: - Initializer
    private init() {}
    
    // MARK: - Methods
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

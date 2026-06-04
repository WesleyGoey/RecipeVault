//
//  TheMealDBService.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation

// MARK: - TheMealDBService Class
class TheMealDBService: TheMealDBServiceProtocol {
    static let shared = TheMealDBService(
        apiRepo: TheMealDBRepository.shared,
        cacheService: MemoryCacheService.shared
    )
    private let apiRepo: TheMealDBRepositoryProtocol
    private let cacheService: MemoryCacheServiceProtocol
    
    // MARK: - Initializer
    init(apiRepo: TheMealDBRepositoryProtocol, cacheService: MemoryCacheServiceProtocol) {
        self.apiRepo = apiRepo
        self.cacheService = cacheService
    }
    
    // MARK: - Search Meals
    func searchMeals(query: String) async throws -> [MealDBRecipe] {
        let cacheKey = query.lowercased()
        
        if let cachedData = cacheService.get(query: cacheKey), !cachedData.isEmpty {
            return cachedData
        }
        
        let results = try await apiRepo.searchMeals(query: query)
        
        cacheService.set(query: cacheKey, result: results)
        
        return results
    }
}

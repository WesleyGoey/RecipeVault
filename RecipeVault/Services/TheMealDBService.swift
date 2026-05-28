//
//  TheMealDBService.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


// MARK: - TheMealDBService
import Foundation

class TheMealDBService: TheMealDBServiceProtocol {
    
    // MARK: - Properties
    static let shared = TheMealDBService(
        apiRepo: TheMealDBRepository.shared,
        cacheService: MemoryCacheService.shared
    )
    
    private let apiRepo: TheMealDBRepositoryProtocol
    private let cacheService: MemoryCacheServiceProtocol
    
    // MARK: - Initializer (Dependency Injection)
    init(apiRepo: TheMealDBRepositoryProtocol, cacheService: MemoryCacheServiceProtocol) {
        self.apiRepo = apiRepo
        self.cacheService = cacheService
    }
    
    // MARK: - Methods
    func searchMeals(query: String) async throws -> [MealDBRecipe] {
        let cacheKey = query.lowercased()
        
        // 1. Cek Data di RAM Cache (Mencegah Network Call berulang)
        if let cachedData = cacheService.get(query: cacheKey), !cachedData.isEmpty {
            return cachedData
        }
        
        // 2. Fetch Data dari Internet via Repository
        let results = try await apiRepo.searchMeals(query: query)
        
        // 3. Simpan Hasil ke Cache
        cacheService.set(query: cacheKey, result: results)
        
        return results
    }
}
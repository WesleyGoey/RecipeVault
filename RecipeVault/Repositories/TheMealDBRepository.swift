//
//  TheMealDBRepository.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation

// MARK: - TheMealDBRepository Class
class TheMealDBRepository: TheMealDBRepositoryProtocol {
    static let shared = TheMealDBRepository()
    private let baseURL = "https://www.themealdb.com/api/json/v1/1"
    private init() {}
    
    // MARK: - Search Meals
    func searchMeals(query: String) async throws -> [MealDBRecipe] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/search.php?s=\(encodedQuery)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(MealResponse.self, from: data)
        
        return response.meals ?? []
    }
}

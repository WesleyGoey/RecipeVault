//
//  TheMealDBService.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 28/05/26.
//


import Foundation

class TheMealDBService {
    static let shared = TheMealDBService()
    let baseURL = "https://www.themealdb.com/api/json/v1/1"
    
    func searchMeals(query: String) async throws -> [MealDBRecipe] {
        guard let url = URL(string: "\(baseURL)/search.php?s=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(MealResponse.self, from: data)
        
        return response.meals ?? []
    }
}
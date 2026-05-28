//
//  SearchViewModel.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var isSearching: Bool = false
    @Published var selectedTab: SearchTab = .theMealDB
    @Published var isLoading: Bool = false
    
    // Data Sources
    @Published var mealDBRecipes: [Recipe] = []
    @Published var collections: [String] = [] // Left empty for "No Public Collection Yet"
    
    enum SearchTab {
        case theMealDB
        case collections
    }
    
    init() {
        // Fetch default data so the trending section isn't empty on load
        Task { await fetchRecipes(query: "Chicken") }
    }
    
    func performSearch() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }
        await fetchRecipes(query: query)
    }
    
    private func fetchRecipes(query: String) async {
        isLoading = true
        do {
            guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/search.php?s=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else { return }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let meals = json["meals"] as? [[String: Any]] {
                
                self.mealDBRecipes = meals.compactMap { meal in
                    let id = meal["idMeal"] as? String ?? UUID().uuidString
                    let title = meal["strMeal"] as? String ?? "Unknown"
                    let category = meal["strCategory"] as? String ?? "General"
                    let image = meal["strMealThumb"] as? String ?? ""
                    let instructions = meal["strInstructions"] as? String ?? ""
                    
                    // 🚀 TheMealDB Ingredient Parser
                    var parsedIngredients: [String] = []
                    for i in 1...20 {
                        if let ingredient = meal["strIngredient\(i)"] as? String,
                           !ingredient.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            let measure = (meal["strMeasure\(i)"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                            let combined = measure.isEmpty ? ingredient : "\(measure) \(ingredient)"
                            parsedIngredients.append(combined)
                        }
                    }
                    
                    let parsedSteps = instructions
                        .components(separatedBy: .newlines)
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                    
                    var recipe = Recipe(
                        userId: "themealdb",
                        title: title,
                        description: "A classic \(category) dish.",
                        ingredients: parsedIngredients, // Passed the parsed data here!
                        steps: parsedSteps,
                        category: category,
                        recipeImage: image,
                        cookingTime: Int.random(in: 15...45),
                        servings: Int.random(in: 2...4)
                    )
                    recipe.id = id
                    recipe.createdAt = Date()
                    return recipe
                }
            } else {
                self.mealDBRecipes = [] // Empty out if search fails/no results
            }
        } catch {
            print("Error fetching from MealDB: \(error.localizedDescription)")
        }
        isLoading = false
    }
}

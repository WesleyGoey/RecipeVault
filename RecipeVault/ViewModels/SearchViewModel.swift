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
    @Published var collections: [String] = [] // Dibiarkan kosong agar menampilkan "No Public Collection Yet"
    
    enum SearchTab {
        case theMealDB
        case collections
    }
    
    init() {
        // Menarik data awal (default) agar layar tidak kosong saat pertama kali ditekan
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
            // Menggunakan API pencarian nama dari TheMealDB
            guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/search.php?s=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else { return }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let meals = json["meals"] as? [[String: Any]] {
                
                // Konversi data MealDB mentah menjadi model Recipe milikmu
                self.mealDBRecipes = meals.compactMap { meal in
                    let id = meal["idMeal"] as? String ?? UUID().uuidString
                    let title = meal["strMeal"] as? String ?? "Unknown"
                    let category = meal["strCategory"] as? String ?? "General"
                    let image = meal["strMealThumb"] as? String ?? ""
                    let instructions = meal["strInstructions"] as? String ?? ""
                    
                    let parsedSteps = instructions
                        .components(separatedBy: .newlines)
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                    
                    var recipe = Recipe(
                        userId: "themealdb",
                        title: title,
                        description: "A classic \(category) dish.",
                        ingredients: ["Ingredients parsing pending..."], // Bisa diparsing lebih detail nanti
                        steps: parsedSteps,
                        category: category,
                        recipeImage: image,
                        cookingTime: Int.random(in: 15...45), // Dummy data karena MealDB tidak punya waktu masak
                        servings: Int.random(in: 2...4)       // Dummy data
                    )
                    recipe.id = id
                    recipe.createdAt = Date()
                    return recipe
                }
            } else {
                self.mealDBRecipes = [] // Kosongkan jika tidak ada hasil
            }
        } catch {
            print("Error fetching from MealDB: \(error.localizedDescription)")
        }
        isLoading = false
    }
}

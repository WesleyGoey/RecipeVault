//
//  HomeViewModel.swift
//  RecipeVault
//
//  Created by Nicholas Gerwin Mawardji on 29/05/26.
//


import Foundation
import SwiftUI
import Combine

// MARK: - HomeViewModel Class
@MainActor
class HomeViewModel: ObservableObject {
    @Published var recipeOfTheDay: Recipe?
    @Published var isLoadingHero: Bool = true
    
    @Published var categories: [String] = ["All"]
    @Published var selectedCategory: String = "All"
    
    @Published var feedRecipes: [Recipe] = []
    @Published var isLoadingFeed: Bool = true
    
    // MARK: - Initializer
    init() {
        Task {
            await fetchRecipeOfTheDay()
            await fetchCategories()
            await fetchFeed(for: "All")
        }
    }
    
    // MARK: - Fetch Recipe Of The Day
    func fetchRecipeOfTheDay() async {
        isLoadingHero = true
        do {
            guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/random.php") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let meals = json["meals"] as? [[String: Any]],
               let meal = meals.first {
                self.recipeOfTheDay = parseMeal(meal)
            }
        } catch {
            print("Failed to fetch Recipe of the Day: \(error.localizedDescription)")
        }
        isLoadingHero = false
    }
    
    // MARK: - Fetch Categories
    func fetchCategories() async {
        do {
            guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/list.php?c=list") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let meals = json["meals"] as? [[String: Any]] {
                
                var fetchedCategories = meals.compactMap { $0["strCategory"] as? String }
                fetchedCategories.sort()
                self.categories = ["All"] + fetchedCategories
            }
        } catch {
            print("Failed to fetch categories: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Select Category
    func selectCategory(_ category: String) {
        guard selectedCategory != category else { return }
        selectedCategory = category
        Task {
            await fetchFeed(for: category)
        }
    }
    
    // MARK: - Fetch Feed
    func fetchFeed(for category: String) async {
        isLoadingFeed = true
        feedRecipes = []
        
        do {
            let urlString: String
            if category == "All" {
                let letters = ["a", "b", "c", "m", "p", "s"]
                let randomLetter = letters.randomElement() ?? "c"
                urlString = "https://www.themealdb.com/api/json/v1/1/search.php?f=\(randomLetter)"
            } else {
                let safeCategory = category.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                urlString = "https://www.themealdb.com/api/json/v1/1/filter.php?c=\(safeCategory)"
            }
            
            guard let url = URL(string: urlString) else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let meals = json["meals"] as? [[String: Any]] {
                
                self.feedRecipes = meals.compactMap { parseMeal($0, forceCategory: category == "All" ? nil : category) }.shuffled()
            }
        } catch {
            print("Failed to fetch feed: \(error.localizedDescription)")
        }
        isLoadingFeed = false
    }
    
    // MARK: - Parse Meal
    private func parseMeal(_ meal: [String: Any], forceCategory: String? = nil) -> Recipe {
        let id = meal["idMeal"] as? String ?? UUID().uuidString
        let title = meal["strMeal"] as? String ?? "Unknown"
        let category = forceCategory ?? (meal["strCategory"] as? String ?? "General")
        let image = meal["strMealThumb"] as? String ?? ""
        let instructions = meal["strInstructions"] as? String ?? ""
        
        var parsedIngredients: [String] = []
        for i in 1...20 {
            if let ingredient = meal["strIngredient\(i)"] as? String, !ingredient.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
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
            description: "A classic dish.",
            ingredients: parsedIngredients,
            steps: parsedSteps,
            category: category,
            recipeImage: image
        )
        recipe.id = id
        recipe.createdAt = Date()
        return recipe
    }
}

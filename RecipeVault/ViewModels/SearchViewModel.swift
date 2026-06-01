//
//  SearchViewModel.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//

import Foundation
import SwiftUI
import Combine

// MARK: - SearchViewModel Class
@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var isSearching: Bool = false
    @Published var selectedTab: SearchTab = .theMealDB
    
    @Published var isLoading: Bool = false
    @Published var isLoadingCollections: Bool = false
    
    @Published var mealDBRecipes: [Recipe] = []
    @Published var collections: [RecipeCollection] = []
    @Published var creatorNames: [String: String] = [:]
    
    private let mealDBService = TheMealDBService.shared
    private let collectionService = CollectionService.shared
    private let profileService = ProfileService.shared
    
    // MARK: - Initializer
    init() {
        Task {
            await performSearch(query: "Chicken")
            await fetchPublicCollections()
        }
    }
    
    // MARK: - Perform Search
    func performSearch(query: String? = nil) async {
        let searchQuery = query ?? searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !searchQuery.isEmpty else { return }
        
        isLoading = true
        mealDBRecipes = []
        
        do {
            let results = try await mealDBService.searchMeals(query: searchQuery)
            
            self.mealDBRecipes = results.map { meal in
                Recipe(
                    id: meal.idMeal,
                    userId: "themealdb",
                    title: meal.strMeal,
                    description: "A classic dish from TheMealDB.",
                    ingredients: [],
                    steps: [],
                    category: meal.strCategory ?? "General",
                    recipeImage: meal.strMealThumb ?? "",
                    createdAt: Date()
                )
            }
        } catch {
            print("Failed to search recipes: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    // MARK: - Fetch Public Collections
    func fetchPublicCollections() async {
        isLoadingCollections = true
        collections = []
        
        do {
            let fetchedCollections = try await collectionService.getPublicCollections()
            self.collections = fetchedCollections
            
            var namesDict: [String: String] = [:]
            let uniqueUserIds = Array(Set(fetchedCollections.map { $0.userId }))
            
            for uid in uniqueUserIds {
                if let userData = try await profileService.getUserProfile(userId: uid),
                   let userName = userData["name"] as? String {
                    namesDict[uid] = userName
                }
            }
            self.creatorNames = namesDict
            
        } catch {
            print("Error fetching public collections: \(error.localizedDescription)")
        }
        isLoadingCollections = false
    }
}

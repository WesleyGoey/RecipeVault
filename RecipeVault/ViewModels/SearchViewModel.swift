//
//  SearchViewModel.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//

import Foundation
import SwiftUI
import Combine
import FirebaseFirestore // 🚀 Wajib ditambahkan untuk mem-bypass error Firebase Index

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
    
    // 🚀 INI DIA PENYEBAB ERROR-NYA: Variabel ini sebelumnya tertinggal!
    @Published var featuredCollections: [RecipeCollection] = []
    
    @Published var creatorNames: [String: String] = [:]
    
    private let mealDBService = TheMealDBService.shared
    
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
        
        do {
            let db = Firestore.firestore()
            // 🚀 Tarik seluruh koleksi lalu filter manual agar tidak terkena limitasi Index Firebase
            let snapshot = try await db.collection("collections").getDocuments()
            
            var fetchedCollections: [RecipeCollection] = []
            var namesDict: [String: String] = [:]
            
            for doc in snapshot.documents {
                let data = doc.data()
                let visibilityString = data["visibility"] as? String ?? ""
                
                // Hanya masukkan koleksi yang bersifat public
                if visibilityString.lowercased().contains("public") {
                    let userId = data["userId"] as? String ?? ""
                    
                    var collection = RecipeCollection(
                        userId: userId,
                        name: data["name"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        collectionImage: data["collectionImage"] as? String ?? "",
                        visibility: .publicVisibility
                    )
                    collection.id = doc.documentID
                    fetchedCollections.append(collection)
                    
                    // Tarik nama user (Kreator)
                    if namesDict[userId] == nil {
                        let userDoc = try? await db.collection("users").document(userId).getDocument()
                        if let userName = userDoc?.data()?["name"] as? String {
                            namesDict[userId] = userName
                        } else {
                            namesDict[userId] = "Chef"
                        }
                    }
                }
            }
            
            self.collections = fetchedCollections
        
            self.featuredCollections = Array(fetchedCollections.shuffled().prefix(2))
            
            self.creatorNames = namesDict
            
        } catch {
            print("Error fetching public collections: \(error.localizedDescription)")
        }
        isLoadingCollections = false
    }
}

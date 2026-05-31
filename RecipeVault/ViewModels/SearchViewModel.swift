//
//  SearchViewModel.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//

import Foundation
import SwiftUI
import Combine
import FirebaseFirestore

@MainActor
class SearchViewModel: ObservableObject {
    // MARK: - Search States
    @Published var searchText: String = ""
    @Published var isSearching: Bool = false
    @Published var selectedTab: SearchTab = .theMealDB
    @Published var isLoading: Bool = false
    
    // MARK: - Data Sources
    @Published var mealDBRecipes: [Recipe] = []
    @Published var collections: [RecipeCollection] = []
    @Published var isLoadingCollections: Bool = false
    
    enum SearchTab {
        case theMealDB
        case collections
    }
    
    init() {
        Task {
            // Tarik data awal untuk mengisi layar "Trending/Discover"
            await performSearch(query: "Chicken")
            // Tarik koleksi publik dari Firebase
            await fetchPublicCollections()
        }
    }
    
    // MARK: - API TheMealDB Search
    // 🚀 Ini adalah fungsi yang dicari-cari oleh Xcode!
    func performSearch(query: String? = nil) async {
        // Gunakan parameter query jika ada (untuk default), jika tidak gunakan searchText dari user
        let searchQuery = query ?? searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Jangan mencari jika kosong
        guard !searchQuery.isEmpty else { return }
        
        isLoading = true
        mealDBRecipes = [] // Bersihkan hasil pencarian sebelumnya
        
        do {
            // Encode query agar aman untuk URL (misal: spasi menjadi %20)
            let safeQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/search.php?s=\(safeQuery)") else { return }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let meals = json["meals"] as? [[String: Any]] {
                self.mealDBRecipes = meals.compactMap { parseMeal($0) }
            }
        } catch {
            print("Failed to search recipes: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // MARK: - Firebase Public Collections
    func fetchPublicCollections() async {
        isLoadingCollections = true
        collections = [] // Bersihkan data lama sebelum mengambil yang baru
        
        do {
            let db = Firestore.firestore()
            // 🚀 Ambil semua koleksi di mana visibility-nya diset "PUBLIC"
            let snapshot = try await db.collection("collections")
                .whereField("visibility", isEqualTo: "PUBLIC")
                .getDocuments()
            
            self.collections = snapshot.documents.compactMap { doc in
                try? doc.data(as: RecipeCollection.self)
            }
        } catch {
            print("Error fetching public collections: \(error.localizedDescription)")
        }
        
        isLoadingCollections = false
    }
    
    // MARK: - Helper (Parse API Response)
    private func parseMeal(_ meal: [String: Any]) -> Recipe {
        let id = meal["idMeal"] as? String ?? UUID().uuidString
        let title = meal["strMeal"] as? String ?? "Unknown"
        let category = meal["strCategory"] as? String ?? "General"
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
            description: "A classic dish from TheMealDB.",
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

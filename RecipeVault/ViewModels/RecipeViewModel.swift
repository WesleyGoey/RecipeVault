//
//  RecipeViewModel.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


// MARK: - RecipeViewModel
import Foundation
import SwiftUI
import Combine

@MainActor
class RecipeViewModel: ObservableObject {
    
    // MARK: - Properties
    @Published var myRecipes: [Recipe] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    
    private let firestoreRepo = FirestoreRepository.shared
    private let authService = AuthService.shared
    
    // MARK: - Methods
    func loadMyRecipes() async {
        guard let uid = authService.getCurrentUID() else { return }
        isLoading = true
        
        do {
            // Catatan: Pastikan kamu menambahkan fungsi getRecipesByUser(userId:) di FirestoreRepository
            // myRecipes = try await firestoreRepo.getRecipesByUser(userId: uid)
            
            // MOCK DATA SEMENTARA UNTUK PREVIEW
            myRecipes = Recipe.mockRecipes
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

// MARK: - Mock Data Extension
extension Recipe {
    static let mockRecipes = [
        Recipe(userId: "123", title: "Mom's Sunday Pasta", description: "Delicious pasta", ingredients: ["Pasta"], steps: ["Boil water"], category: "Italian", recipeImage: "https://www.themealdb.com/images/media/meals/sutysw1468247559.jpg"),
        Recipe(userId: "123", title: "Blueberry Pavlova", description: "Sweet dessert", ingredients: ["Blueberry"], steps: ["Bake"], category: "Dessert", recipeImage: "https://www.themealdb.com/images/media/meals/adxcjq1628770918.jpg")
    ]
}

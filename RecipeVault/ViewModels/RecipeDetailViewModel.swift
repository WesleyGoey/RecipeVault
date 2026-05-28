//
//  RecipeDetailViewModel.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 28/05/26.
//


// MARK: - RecipeDetailViewModel
import Foundation
import SwiftUI
import Combine

@MainActor
class RecipeDetailViewModel: ObservableObject {
    // MARK: - UI State
    @Published var recipe: Recipe
    @Published var isFavorite: Bool = false
    @Published var currentTab: DetailTab = .ingredients
    
    // MARK: - Collection Bottom Sheet State
    @Published var showCollectionSheet: Bool = false
    @Published var userCollections: [RecipeCollection] = []
    @Published var selectedCollectionIds: Set<String> = []
    @Published var isSavingToCollections: Bool = false
    
    enum DetailTab {
        case ingredients
        case steps
    }
    
    // Deklarasi dependensi baru sesuai arsitektur flat
    private let firestoreRepo = FirestoreRepository.shared
    private let collectionService = CollectionService.shared
    private let authService = AuthService.shared
    
    init(recipe: Recipe) {
        self.recipe = recipe
        Task {
            await checkIfFavorite()
        }
    }
    
    // MARK: - Favorite Actions
    func toggleFavorite() async {
        isFavorite.toggle() // Optimistic UI update
        // TODO: Call FavoriteService to add/remove favorite
    }
    
    func checkIfFavorite() async {
        // TODO: Check Firestore if this is already favorited
    }
    
    // MARK: - Collection Actions
    
    /// Called when the '+' button is tapped
    func openCollectionSheet() async {
        showCollectionSheet = true
        await fetchUserCollections()
    }
    
    /// Fetches the user's folders to populate the bottom sheet
    func fetchUserCollections() async {
        guard let uid = authService.getCurrentUID() else { return }
        
        do {
            // Operasi Mambaca -> Menggunakan Repository
            userCollections = try await firestoreRepo.getUserCollections(userId: uid)
            print("Fetched \(userCollections.count) collections for bottom sheet!")
        } catch {
            print("Error fetching collections: \(error.localizedDescription)")
        }
    }
    
    /// Toggles the tick box for a specific collection in the bottom sheet
    func toggleCollectionSelection(collectionId: String) {
        if selectedCollectionIds.contains(collectionId) {
            selectedCollectionIds.remove(collectionId)
        } else {
            selectedCollectionIds.insert(collectionId)
        }
    }
    
    /// Called when the user hits "Done" on the bottom sheet
    func saveToSelectedCollections() async {
        guard let recipeId = recipe.id else { return }
        isSavingToCollections = true
        
        do {
            for collectionId in selectedCollectionIds {
                // Operasi Menulis (Business Logic) -> Menggunakan Service
                try await collectionService.addRecipeToCollection(collectionId: collectionId, recipeId: recipeId)
            }
            showCollectionSheet = false
            selectedCollectionIds.removeAll() // Clear after saving
        } catch {
            print("Error saving to collections: \(error.localizedDescription)")
        }
        
        isSavingToCollections = false
    }
}

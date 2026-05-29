//
//  CollectionViewModel.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//

import Foundation
import SwiftUI
import Combine

// MARK: - View State Enum
enum ViewState: Equatable {
    case idle
    case loading
    case success
    case error(String)
}

// MARK: - Collection ViewModel
@MainActor
final class CollectionViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var collections: [Collection] = []
    @Published var collectionRecipes: [Recipe] = [] // Model Recipe diasumsikan sudah ada
    @Published var viewState: ViewState = .idle
    
    // MARK: - Dependencies
    private let collectionService: CollectionServiceProtocol
    private let recipeService: RecipeServiceProtocol
    
    // MARK: - Initializer
    init(collectionService: CollectionServiceProtocol, recipeService: RecipeServiceProtocol) {
        self.collectionService = collectionService
        self.recipeService = recipeService
    }
    
    // MARK: - Fetch Methods
    
    /// Mengambil detail resep untuk sebuah koleksi menggunakan junction table CollectionRecipe
    func fetchRecipesForCollection(collectionId: String) async {
        viewState = .loading
        
        do {
            // 1. Ambil junction data (relasi) dari Service/Repository
            // Asumsi: collectionService memiliki metode getCollectionRecipes(collectionId:)
            let junctionData = try await collectionService.getCollectionRecipes(collectionId: collectionId)
            
            // 2. Ekstrak array recipeId
            let recipeIds = junctionData.map { $0.recipeId }
            
            guard !recipeIds.isEmpty else {
                self.collectionRecipes = []
                self.viewState = .success
                return
            }
            
            // 3. Fetch data Recipe asli berdasarkan daftar ID
            // Asumsi: recipeService memiliki metode getRecipes(byIds:)
            let fetchedRecipes = try await recipeService.getRecipes(byIds: recipeIds)
            
            self.collectionRecipes = fetchedRecipes
            self.viewState = .success
            
        } catch {
            self.viewState = .error("Gagal memuat isi koleksi. Periksa koneksi internet Anda.")
        }
    }
}

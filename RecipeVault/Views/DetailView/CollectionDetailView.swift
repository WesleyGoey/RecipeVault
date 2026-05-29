//
//  CollectionDetailView.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 27/05/26.
//

import SwiftUI

// MARK: - Collection Detail View
struct CollectionDetailView: View {
    
    // MARK: - Properties
    let collection: Collection
    @StateObject private var viewModel: CollectionViewModel
    
    // Grid Configuration
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    // MARK: - Initializer
    init(collection: Collection, viewModel: CollectionViewModel) {
        self.collection = collection
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color(hex: "f8fae5").ignoresSafeArea() // bgYellow
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    headerSection
                    descriptionSection
                    recipesGridSection
                }
                .padding(.bottom, 32)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Fetch data saat view muncul
            guard let collectionId = collection.id else { return }
            await viewModel.fetchRecipesForCollection(collectionId: collectionId)
        }
    }
}

// MARK: - Sub-views (SRP)
extension CollectionDetailView {
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Cover Image
            AsyncImage(url: URL(string: collection.collectionImage)) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Rectangle()
                        .fill(Color(hex: "43766c").opacity(0.2)) // mutedTeal
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(Color(hex: "43766c"))
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 200, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
            .padding(.top, 24)
            
            // Title & Visibility Badge
            VStack(spacing: 8) {
                Text(collection.name)
                    .font(.custom("Merriweather-Bold", size: 24))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 6) {
                    Image(systemName: collection.isPublic() ? "globe" : "lock.fill")
                    Text(collection.visibility.rawValue.capitalized)
                }
                .font(.custom("Merriweather-Regular", size: 14))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(hex: "43766c").opacity(0.1)) // mutedTeal
                .foregroundColor(Color(hex: "43766c"))
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Description Section
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tentang Koleksi Ini")
                .font(.custom("Merriweather-Bold", size: 18))
                .foregroundColor(.primary)
            
            Text(collection.description.isEmpty ? "Tidak ada deskripsi." : collection.description)
                .font(.custom("Merriweather-Regular", size: 16))
                .foregroundColor(.secondary)
                .lineSpacing(4)
            
            // Creator info (Bisa di-tap untuk ke Profile nanti)
            HStack {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(Color(hex: "cd4b12")) // burntOrange
                Text("Dibuat oleh pengguna terdaftar")
                    .font(.custom("Merriweather-Regular", size: 14))
                    .foregroundColor(.primary)
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Recipes Grid Section
    private var recipesGridSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Resep (\(viewModel.collectionRecipes.count))")
                .font(.custom("Merriweather-Bold", size: 18))
                .padding(.horizontal, 20)
            
            switch viewModel.viewState {
            case .loading:
                ProgressView("Memuat resep...")
                    .frame(maxWidth: .infinity)
                    .padding(.top, 32)
            case .error(let message):
                Text(message)
                    .font(.custom("Merriweather-Regular", size: 14))
                    .foregroundColor(Color(hex: "cd4b12")) // burntOrange
                    .frame(maxWidth: .infinity)
                    .padding(.top, 32)
            case .success, .idle:
                if viewModel.collectionRecipes.isEmpty {
                    emptyStateView
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.collectionRecipes) { recipe in
                            // Asumsi RecipeCardView sudah kamu buat dari Tab 3
                            Text(recipe.title) // Fallback placeholder
                                .frame(height: 150)
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.05), radius: 4)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: "43766c").opacity(0.4))
            
            Text("Belum ada resep di koleksi ini.")
                .font(.custom("Merriweather-Regular", size: 16))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 32)
    }
}

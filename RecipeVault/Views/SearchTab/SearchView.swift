//
//  SearchView.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 27/05/26.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @EnvironmentObject var recipeViewModel: RecipeViewModel
    @FocusState private var isSearchFocused: Bool
    
    // 🚀 State untuk menampung 2 koleksi acak di halaman depan
    @State private var featuredCollections: [RecipeCollection] = []

    // Theme Colors
    let bgYellow = Color(hex: "f8fae5")
    let burntOrange = Color(hex: "cd4b12")
    let mutedTeal = Color(hex: "43766c")
    let darkText = Color.primary

    // Grid Setup untuk 2 Kolom (Hasil Pencarian)
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // MARK: - FIXED HEADER AREA
                VStack(alignment: .leading, spacing: 0) {

                    // 1. Title
                    if !viewModel.isSearching {
                        Text("Discover")
                            .font(.merriweather(36, weight: .bold))
                            .foregroundColor(darkText)
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                            .padding(.bottom, 16)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    } else {
                        Spacer().frame(height: 20)
                    }

                    // 2. Search Bar & Cancel Button
                    HStack(spacing: 12) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .font(.system(size: 18, weight: .semibold))

                            TextField("Search recipes & collections", text: $viewModel.searchText)
                                .focused($isSearchFocused)
                                .font(.merriweather(16, weight: .regular))
                                .submitLabel(.search)
                                .onSubmit {
                                    Task { await viewModel.performSearch() }
                                }
                                .onChange(of: isSearchFocused) { isFocused in
                                    if isFocused {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            viewModel.isSearching = true
                                        }
                                    }
                                }

                            if !viewModel.searchText.isEmpty {
                                Button(action: { viewModel.searchText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray.opacity(0.6))
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)

                        if viewModel.isSearching {
                            Button("Cancel") {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    viewModel.isSearching = false
                                    viewModel.searchText = ""
                                    isSearchFocused = false
                                }
                            }
                            .font(.merriweather(16, weight: .bold))
                            .foregroundColor(mutedTeal)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 24)

                    // 3. Segmented Tabs
                    if viewModel.isSearching {
                        HStack(spacing: 0) {
                            SearchPickerTab(title: "TheMealDB", isSelected: viewModel.selectedTab == .theMealDB) {
                                withAnimation(.easeInOut(duration: 0.2)) { viewModel.selectedTab = .theMealDB }
                            }
                            SearchPickerTab(title: "Collections", isSelected: viewModel.selectedTab == .collections) {
                                withAnimation(.easeInOut(duration: 0.2)) { viewModel.selectedTab = .collections }
                            }
                        }
                        .padding(6)
                        .background(mutedTeal.opacity(0.15))
                        .clipShape(Capsule())
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(.bottom, 10)
                .background(bgYellow)
                .zIndex(1)

                // MARK: - SCROLLABLE CONTENT AREA
                ScrollView {
                    if !viewModel.isSearching {
                        discoveryFeed
                    } else {
                        if viewModel.selectedTab == .theMealDB {
                            mealDBGrid
                        } else {
                            collectionsGrid
                        }
                    }
                }
                .background(bgYellow)
            }
            .background(bgYellow.ignoresSafeArea())
            .onAppear {
                Task { await viewModel.fetchPublicCollections() }
            }
            // 🚀 Ambil 2 acak saat koleksi Firebase berhasil diunduh
            .onChange(of: viewModel.collections) { collections in
                if !collections.isEmpty {
                    featuredCollections = Array(collections.shuffled().prefix(2))
                }
            }
        }
    }
}

// MARK: - Subviews
extension SearchView {

    // MARK: - Discovery Feed (Default State)
    private var discoveryFeed: some View {
        VStack(alignment: .leading, spacing: 32) {

            // SECTION 1: EDITOR'S PICK
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("EDITOR'S PICK")
                        .font(.system(size: 11, weight: .bold, design: .default))
                        .tracking(1.5)
                        .foregroundColor(burntOrange)
                    Text("Featured Collections")
                        .font(.merriweather(24, weight: .bold))
                        .foregroundColor(darkText)
                }
                .padding(.horizontal, 24)

                // 🚀 MENGGUNAKAN 2 DATA FIREBASE ACAK & BISA DITEKAN
                VStack(spacing: 20) {
                    if viewModel.isLoadingCollections {
                        ProgressView()
                    } else if featuredCollections.isEmpty {
                        Text("No featured collections available.")
                            .font(.merriweather(14, weight: .regular))
                            .foregroundColor(.gray)
                            .padding(.leading, 24)
                    } else {
                        ForEach(featuredCollections) { collection in
                            OptimizedCollectionLink(
                                collection: collection,
                                creatorNames: viewModel.creatorNames
                            )
                        }
                    }
                }
                .padding(.horizontal, 24)
            }

            // SECTION 2: WHAT'S HOT
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("WHAT'S HOT")
                        .font(.system(size: 11, weight: .bold, design: .default))
                        .tracking(1.5)
                        .foregroundColor(mutedTeal)
                    Text("Trending Recipes")
                        .font(.merriweather(24, weight: .bold))
                        .foregroundColor(darkText)
                }
                .padding(.horizontal, 24)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        if viewModel.mealDBRecipes.isEmpty {
                            ProgressView()
                                .padding(.leading, 24)
                        } else {
                            // 🚀 MENGGUNAKAN STRUCT OPTIMASI
                            ForEach(viewModel.mealDBRecipes.prefix(5)) { recipe in
                                OptimizedRecipeLink(recipe: recipe, recipeVM: recipeViewModel)
                            }
                        }
                    }
                    .padding(.leading, 24)
                    .padding(.trailing, 24)
                }
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 120)
    }

    // MARK: - Search Results Grid
    private var mealDBGrid: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
            } else if viewModel.mealDBRecipes.isEmpty {
                Text("No recipes found.")
                    .font(.merriweather(16, weight: .regular))
                    .foregroundColor(.gray)
                    .padding(.top, 40)
            } else {
                // 🚀 MENGGUNAKAN STRUCT OPTIMASI
                ForEach(viewModel.mealDBRecipes) { recipe in
                    OptimizedRecipeLink(recipe: recipe, recipeVM: recipeViewModel)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
        .padding(.bottom, 120)
    }

    // MARK: - Collections Grid
    private var collectionsGrid: some View {
        VStack {
            if viewModel.isLoadingCollections {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding(.top, 40)
            } else if viewModel.collections.isEmpty {
                Spacer().frame(height: 80)
                Image(systemName: "folder.badge.questionmark")
                    .font(.system(size: 50))
                    .foregroundColor(mutedTeal.opacity(0.5))

                Text("No Public Collection Yet")
                    .font(.merriweather(20, weight: .bold))
                    .foregroundColor(darkText)
                    .padding(.top, 16)

                Text("When users create public collections, they will appear here.")
                    .font(.merriweather(14, weight: .regular))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
                    .padding(.horizontal, 40)
            } else {
                LazyVGrid(columns: columns, spacing: 20) {
                    // 🚀 MENGGUNAKAN STRUCT OPTIMASI
                    ForEach(viewModel.collections) { collection in
                        OptimizedCollectionLink(
                            collection: collection,
                            creatorNames: viewModel.creatorNames
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)
                .padding(.bottom, 120)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 🚀 STRUCT OPTIMASI (Jangan dihapus agar Xcode tidak ngelag!)

// 1. Struct untuk Kartu Koleksi Publik (Meringankan Compile)
struct OptimizedCollectionLink: View {
    let collection: RecipeCollection
    let creatorNames: [String: String]
    
    var body: some View {
        let authorName = creatorNames[collection.userId] ?? "Chef"
        let validImage = collection.collectionImage.isEmpty ? "https://images.unsplash.com/photo-1495195134817-a165d4292816?q=80&w=800&auto=format&fit=crop" : collection.collectionImage
        
        NavigationLink(destination: CollectionDetailView(collection: collection, viewModel: CollectionViewModel())) {
            DiscoverCardView(
                title: collection.name,
                author: "@\(authorName.uppercased().replacingOccurrences(of: " ", with: "_"))",
                recipeCount: 0,
                imageUrl: validImage
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 2. Struct untuk Kartu Resep (Meringankan Compile)
struct OptimizedRecipeLink: View {
    let recipe: Recipe
    @ObservedObject var recipeVM: RecipeViewModel
    
    var body: some View {
        // 🚀 PERBAIKAN: Gunakan 'recipeVM' yang di-passing, JANGAN 'RecipeViewModel()'
        NavigationLink(destination: RecipeDetailView(recipe: recipe, viewModel: recipeVM)) {
            RecipeCardView(recipe: recipe, viewModel: recipeVM)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
// 3. Helper Component Tab
private struct SearchPickerTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.merriweather(16, weight: .bold))
                .foregroundColor(isSelected ? .black : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? Color.white : Color.clear)
                .clipShape(Capsule())
                .shadow(color: isSelected ? .black.opacity(0.05) : .clear, radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Preview
#Preview {
    SearchView()
}

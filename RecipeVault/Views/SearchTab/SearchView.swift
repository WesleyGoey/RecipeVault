//
//  SearchView.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 27/05/26.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @FocusState private var isSearchFocused: Bool
    
    // Theme Colors
    let bgYellow = Color(hex: "f8fae5")
    let burntOrange = Color(hex: "cd4b12")
    let mutedTeal = Color(hex: "43766c")
    let darkText = Color.primary
    
    // Grid Setup untuk 2 Kolom (Hasil Pencarian)
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // MARK: - FIXED HEADER AREA
                VStack(alignment: .leading, spacing: 0) {
                    
                    // 1. Title
                    if !viewModel.isSearching {
                        Text("Discover")
                            // 🚀 Font Fix
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
                                // 🚀 Font Fix
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
                            // 🚀 Font Fix
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
            // 🚀 Refresh Public Collections setiap kali layar Search dibuka
            .onAppear {
                Task { await viewModel.fetchPublicCollections() }
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
                        // 🚀 Font Fix
                        .font(.merriweather(24, weight: .bold))
                        .foregroundColor(darkText)
                }
                .padding(.horizontal, 24)
                
                VStack(spacing: 20) {
                    DiscoverCardView(
                        title: "Quick Weeknight Dinners",
                        author: "@CHEF_MARIA",
                        recipeCount: 24,
                        imageUrl: "https://images.unsplash.com/photo-1556910103-1c02745aae4d?q=80&w=800&auto=format&fit=crop"
                    )
                    
                    DiscoverCardView(
                        title: "Baking Essentials",
                        author: "@BAKE_WITH_LOVE",
                        recipeCount: 31,
                        imageUrl: "https://images.unsplash.com/photo-1556911220-e15b29be8c8f?q=80&w=800&auto=format&fit=crop"
                    )
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
                        // 🚀 Font Fix
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
                            ForEach(viewModel.mealDBRecipes.prefix(5)) { recipe in
                                NavigationLink(destination: RecipeDetailView(recipe: recipe, viewModel: RecipeViewModel())) {
                                    RecipeCardView(recipe: recipe)
                                }
                                .buttonStyle(PlainButtonStyle())
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
                    // 🚀 Font Fix
                    .font(.merriweather(16, weight: .regular))
                    .foregroundColor(.gray)
                    .padding(.top, 40)
            } else {
                ForEach(viewModel.mealDBRecipes) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe, viewModel: RecipeViewModel())) {
                        RecipeCardView(recipe: recipe)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
        .padding(.bottom, 120)
    }
    
    // MARK: - Collections Grid (🚀 PERBAIKAN UTAMA DI SINI)
    private var collectionsGrid: some View {
        VStack {
            if viewModel.isLoadingCollections {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding(.top, 40)
            }
            else if viewModel.collections.isEmpty {
                // Layar Kosong jika belum ada koleksi publik
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
            }
            else {
                // 🚀 JIKA ADA DATA KOLEKSI: Tampilkan Grid Kartu!
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.collections) { collection in
                        // 🚀 TAMBAHKAN NAVIGATION LINK INI
                        NavigationLink(destination: CollectionDetailView(collection: collection, viewModel: CollectionViewModel())) {
                            DiscoverCardView(
                                title: collection.name,
                                author: "PUBLIC",
                                recipeCount: 0,
                                imageUrl: collection.collectionImage
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
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

// MARK: - Helper Component
fileprivate struct SearchPickerTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                // 🚀 Font Fix
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

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
                // Header statis di luar ScrollView agar tidak ikut tergulir
                VStack(alignment: .leading, spacing: 0) {
                    
                    // 1. Title (Hanya muncul jika TIDAK sedang mencari)
                    if !viewModel.isSearching {
                        Text("Discover")
                            .font(.custom("Merriweather-Bold", size: 36))
                            .foregroundColor(darkText)
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                            .padding(.bottom, 16)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    } else {
                        // Ruang kosong untuk margin atas saat searching
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
                                .submitLabel(.search)
                                .onSubmit {
                                    Task { await viewModel.performSearch() }
                                }
                                // Memicu animasi secara otomatis saat search bar ditekan/mendapat fokus
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
                        
                        // Cancel Button dengan animasi muncul dari kanan
                        if viewModel.isSearching {
                            Button("Cancel") {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    viewModel.isSearching = false
                                    viewModel.searchText = ""
                                    isSearchFocused = false
                                }
                            }
                            .font(.custom("Merriweather-Bold", size: 16))
                            .foregroundColor(mutedTeal)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // 3. Segmented Tabs (Hanya muncul saat searching)
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
                .zIndex(1) // Memastikan header selalu di atas ScrollView saat animasi
                
                // MARK: - SCROLLABLE CONTENT AREA
                ScrollView {
                    if !viewModel.isSearching {
                        // Memanggil UI Feed Utama (Default State)
                        discoveryFeed
                    } else {
                        // Memanggil Tampilan berdasarkan Tab yang dipilih saat pencarian aktif
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
        }
    }
}

// MARK: - Subviews
extension SearchView {
    
    // MARK: - Discovery Feed (Default State)
    private var discoveryFeed: some View {
        VStack(alignment: .leading, spacing: 32) {
            
            // SECTION 1: EDITOR'S PICK (Featured Collections)
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("EDITOR'S PICK")
                        .font(.system(size: 11, weight: .bold, design: .default))
                        .tracking(1.5)
                        .foregroundColor(burntOrange)
                    Text("Featured Collections")
                        .font(.custom("Merriweather-Bold", size: 24))
                        .foregroundColor(darkText)
                }
                .padding(.horizontal, 24)
                
                VStack(spacing: 20) {
                    // Menggunakan DiscoverCardView buatanmu
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
            
            // SECTION 2: WHAT'S HOT (Trending Recipes)
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("WHAT'S HOT")
                        .font(.system(size: 11, weight: .bold, design: .default))
                        .tracking(1.5)
                        .foregroundColor(mutedTeal)
                    Text("Trending Recipes")
                        .font(.custom("Merriweather-Bold", size: 24))
                        .foregroundColor(darkText)
                }
                .padding(.horizontal, 24)
                
                // Horizontal Scroll untuk Resep Trending
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        if viewModel.mealDBRecipes.isEmpty {
                            ProgressView()
                                .padding(.leading, 24)
                        } else {
                            // Menampilkan 5 resep pertama dari MealDB sebagai "Trending"
                            ForEach(viewModel.mealDBRecipes.prefix(5)) { recipe in
                                NavigationLink(destination: RecipeDetailView(viewModel: RecipeDetailViewModel(recipe: recipe))) {
                                    RecipeCardView(recipe: recipe)
                                        .frame(width: 170) // Membatasi lebar agar bisa di-scroll horizontal
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
        .padding(.bottom, 120) // Ruang ekstra di bawah agar tidak tertutup Custom Tab Bar
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
                    .font(.custom("Merriweather-Regular", size: 16))
                    .foregroundColor(.gray)
                    .padding(.top, 40)
            } else {
                ForEach(viewModel.mealDBRecipes) { recipe in
                    // 🚀 NavigationLink untuk setiap hasil pencarian
                    NavigationLink(destination: RecipeDetailView(viewModel: RecipeDetailViewModel(recipe: recipe))) {
                        RecipeCardView(recipe: recipe)
                    }
                    .buttonStyle(PlainButtonStyle()) // Menghapus highlight biru saat ditekan
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
        .padding(.bottom, 120)
    }
    
    // MARK: - Collections Grid (Empty State)
    private var collectionsGrid: some View {
        VStack {
            if viewModel.collections.isEmpty {
                Spacer().frame(height: 80)
                Image(systemName: "folder.badge.questionmark")
                    .font(.system(size: 50))
                    .foregroundColor(mutedTeal.opacity(0.5))
                
                Text("No Public Collection Yet")
                    .font(.custom("Merriweather-Bold", size: 20))
                    .foregroundColor(darkText)
                    .padding(.top, 16)
                
                Text("When users create public collections, they will appear here.")
                    .font(.custom("Merriweather-Regular", size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Helper Component (Fileprivate agar tidak bentrok dengan RecipeDetailView)
fileprivate struct SearchPickerTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Merriweather-Bold", size: 16, relativeTo: .headline))
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

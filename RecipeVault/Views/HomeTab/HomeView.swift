//
//  HomeView.swift
//  RecipeVault
//
//  Created by Nicholas Gerwin Mawardji on 29/05/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var recipeVM: RecipeViewModel
    
    // Theme Colors
    let bgYellow = Color(hex: "f8fae5")
    let mutedTeal = Color(hex: "43766c")
    let darkText = Color.primary
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    
                    // MARK: - 1. Title Area
                    Text("Recipe Vault")
                        .font(.merriweather(40, weight: .bold))
                        .foregroundColor(darkText)
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                    
                    // MARK: - 2. Hero Section (Recipe of the Day)
                    if viewModel.isLoadingHero {
                        ProgressView()
                            .frame(height: 320)
                            .frame(maxWidth: .infinity)
                    } else if let heroRecipe = viewModel.recipeOfTheDay {
                        NavigationLink(destination: RecipeDetailView(recipe: heroRecipe, viewModel: recipeVM)) {
                            // 🚀 PERBAIKAN: Hapus parameter recipeVM karena sudah ditarik otomatis oleh HomeCardView
                            HomeCardView(recipe: heroRecipe)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 24)
                    }
                    
                    // MARK: - 3. Quick Browse (Category Filter)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Quick Browse")
                            .font(.merriweather(20, weight: .bold))
                            .foregroundColor(darkText)
                            .padding(.horizontal, 24)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.categories, id: \.self) { category in
                                    CategoryPill(
                                        title: category,
                                        isSelected: viewModel.selectedCategory == category
                                    ) {
                                        withAnimation(.easeInOut) {
                                            viewModel.selectCategory(category)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    
                    // MARK: - 4. Dynamic Feed Area (Zig-Zag / Masonry)
                    VStack(alignment: .leading, spacing: 20) {
                        // Feed Header
                        HStack(alignment: .bottom) {
                            Text(viewModel.selectedCategory == "All" ? "Today's Feed" : viewModel.selectedCategory)
                                .font(.merriweather(24, weight: .bold))
                                .foregroundColor(darkText)
                            
                            Spacer()
                            
                            if !viewModel.isLoadingFeed {
                                Text("\(viewModel.feedRecipes.count) recipes")
                                    .font(.merriweather(14, weight: .regular))
                                    .foregroundColor(.gray)
                                    .padding(.bottom, 2)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Feed Content
                        if viewModel.isLoadingFeed {
                            ProgressView()
                                .scaleEffect(1.5)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 40)
                        } else if viewModel.feedRecipes.isEmpty {
                            VStack(spacing: 12) {
                                Text("No \(viewModel.selectedCategory.lowercased()) recipes yet")
                                    .font(.merriweather(18, weight: .bold))
                                    .foregroundColor(mutedTeal)
                                Text("Try another category")
                                    .font(.merriweather(14, weight: .regular))
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 40)
                        } else {
                            // 🚀 MASONRY / ZIG-ZAG LAYOUT
                            HStack(alignment: .top, spacing: 16) {
                                
                                // KOLOM KIRI (Hanya berisi index Genap: 0, 2, 4...)
                                VStack(spacing: 16) {
                                    ForEach(Array(viewModel.feedRecipes.enumerated()).filter { $0.offset % 2 == 0 }, id: \.element.id) { index, recipe in
                                        NavigationLink(destination: RecipeDetailView(recipe: recipe, viewModel: recipeVM)) {
                                            // 🚀 PERBAIKAN: Hapus parameter recipeVM
                                            FeedCardView(recipe: recipe, cardHeight: (index % 4 == 0) ? 280 : 220)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                
                                // KOLOM KANAN (Hanya berisi index Ganjil: 1, 3, 5...)
                                VStack(spacing: 16) {
                                    ForEach(Array(viewModel.feedRecipes.enumerated()).filter { $0.offset % 2 != 0 }, id: \.element.id) { index, recipe in
                                        NavigationLink(destination: RecipeDetailView(recipe: recipe, viewModel: recipeVM)) {
                                            // 🚀 PERBAIKAN: Hapus parameter recipeVM
                                            FeedCardView(recipe: recipe, cardHeight: (index % 4 == 3) ? 280 : 220)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                }
                .padding(.bottom, 120)
            }
            .background(bgYellow.ignoresSafeArea())
        }
    }
}

// MARK: - Helper Component: Category Pill Button
struct CategoryPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    let mutedTeal = Color(hex: "43766c")
    let bgYellow = Color(hex: "f8fae5")
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.merriweather(16, weight: .bold))
                .foregroundColor(isSelected ? .white : mutedTeal)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(isSelected ? mutedTeal : Color.clear)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(mutedTeal, lineWidth: isSelected ? 0 : 1.5)
                )
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(RecipeViewModel()) // Wajib untuk mencegah Preview Crash
}

//
//  MyRecipesView.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


// MARK: - MyRecipesView
import SwiftUI

struct MyRecipesView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel = RecipeViewModel()
    @State private var showingCreateSheet = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    // Theme Colors
    let bgYellow = Color(hex: "f8fae5")
    let mutedTeal = Color(hex: "43766c")
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                // Background Utama
                bgYellow.ignoresSafeArea()
                
                // Header dan Grid
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        headerSection
                        gridSection
                    }
                }
                
                // Tombol aksi melayang (FAB)
                floatingActionButton
            }
            .navigationBarHidden(true)
            .task {
                if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                    viewModel.myRecipes = Recipe.previewMockData
                } else {
                    await viewModel.loadMyRecipes()
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                // 🚀 REVISI: Membuka Form Create Recipe sungguhan
                RecipeCreateView()
            }
        }
    }
}

// MARK: - Subviews
extension MyRecipesView {
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("My Recipes")
                .font(.custom("Merriweather-Bold", size: 36))
                .foregroundColor(Color.primary)
            
            Text("\(viewModel.myRecipes.count) created")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 16)
    }
    
    private var gridSection: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(viewModel.myRecipes, id: \.title) { recipe in
                // 🚀 REVISI: Mengarahkan tap kartu ke RecipeDetailView
                NavigationLink(destination: RecipeDetailView(viewModel: RecipeDetailViewModel(recipe: recipe))) {
                    RecipeCardView(recipe: recipe)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 120)
    }
    
    private var floatingActionButton: some View {
        Button(action: {
            showingCreateSheet = true
        }) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 64, height: 64)
                .background(mutedTeal)
                .clipShape(Circle())
                .shadow(color: mutedTeal.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 24)
    }
}

// MARK: - 🚀 Preview Mock Data Extension
extension Recipe {
    static let previewMockData = [
        Recipe(
            userId: "123",
            title: "Mom's Sunday Pasta",
            description: "Resep pasta turun temurun hari minggu.",
            ingredients: [], steps: [],
            category: "Italian",
            recipeImage: "https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?q=80&w=500&auto=format&fit=crop"
        ),
        Recipe(
            userId: "123",
            title: "Lemon Herb Roast Chicken",
            description: "Ayam panggang juicy dengan perasan lemon segar.",
            ingredients: [], steps: [],
            category: "Dinner",
            recipeImage: "https://images.unsplash.com/photo-1598103442097-8b74394b98c6?q=80&w=500&auto=format&fit=crop"
        ),
        Recipe(
            userId: "123",
            title: "Blueberry Pavlova",
            description: "Kue meringue renyah dengan topping berry melimpah.",
            ingredients: [], steps: [],
            category: "Dessert",
            recipeImage: "https://images.unsplash.com/photo-1464305795204-6f5bbfc7fb81?q=80&w=500&auto=format&fit=crop"
        ),
        Recipe(
            userId: "123",
            title: "Weekend Shakshuka",
            description: "Telur ceplok saus tomat pedas khas Timur Tengah.",
            ingredients: [], steps: [],
            category: "Brunch",
            recipeImage: "https://images.unsplash.com/photo-1590412200988-a436bb705300?q=80&w=500&auto=format&fit=crop"
        ),
        Recipe(
            userId: "123",
            title: "Indonesian Soto Ayam",
            description: "Soto ayam kuah kuning hangat yang kaya rempah.",
            ingredients: [], steps: [],
            category: "Soto",
            recipeImage: "https://images.unsplash.com/photo-1626804475315-943482bcb563?q=80&w=500&auto=format&fit=crop"
        ),
        Recipe(
            userId: "123",
            title: "Classic Creamy Ramen",
            description: "Mi kuah kaldu kental gurih ala Kopitiam.",
            ingredients: [], steps: [],
            category: "Noodles",
            recipeImage: "https://images.unsplash.com/photo-1569718212165-3a8278d5f624?q=80&w=500&auto=format&fit=crop"
        )
    ]
}

// MARK: - Preview
#Preview {
    MyRecipesView()
}

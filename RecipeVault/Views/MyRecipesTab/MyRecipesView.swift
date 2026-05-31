//
//  MyRecipesView.swift
//  RecipeVault
//
//  Created by Nicholas Gerwin Mawardji on 29/05/26.
//

import SwiftUI

// MARK: - My Recipes Main View
struct MyRecipesView: View {
    @StateObject private var viewModel = RecipeViewModel()
    
    @State private var showingCreateSheet = false
    @State private var recipeToEdit: Recipe? = nil
    @State private var recipeToDelete: Recipe? = nil
    @State private var showingDeleteAlert = false
    
    private let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
    
    // Theme Colors
    let bgYellow = Color(hex: "f8fae5")
    let mutedTeal = Color(hex: "43766c")
    let burntOrange = Color(hex: "cd4b12")
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                bgYellow.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        headerSection
                        gridSection
                    }
                }
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
            
            // 🚀 MODIFIER SHEET DITEMPATKAN DI PARENT VIEW UTAMA
            .sheet(isPresented: $viewModel.showCollectionSheet) {
                CollectionSelectionSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $showingCreateSheet) {
                // Pastikan RecipeCreateView sudah kamu buat
                RecipeCreateView(viewModel: viewModel)
            }
            .sheet(item: $recipeToEdit) { recipe in
                // Pastikan RecipeEditView sudah kamu buat
                RecipeEditView(recipeToEdit: recipe, viewModel: viewModel)
            }
            
            // Alert Hapus Resep
            .alert("Delete Recipe", isPresented: $showingDeleteAlert, presenting: recipeToDelete) { recipe in
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task { await viewModel.deleteRecipe(recipe: recipe) }
                }
            } message: { recipe in
                Text("Are you sure you want to delete '\(recipe.title)'? This action cannot be undone.")
            }
            
            // Alert Error Umum
            .alert("Terjadi Kesalahan", isPresented: Binding(
                get: { !viewModel.operationError.isEmpty },
                set: { if !$0 { viewModel.operationError = "" } }
            )) {
                Button("OK", role: .cancel) { viewModel.operationError = "" }
            } message: {
                Text(viewModel.operationError)
            }
        }
    }
}

// MARK: - Subviews Extension
extension MyRecipesView {
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("My Recipes")
                .font(.merriweather(36, weight: .bold))
                .foregroundColor(Color.primary)
            
            Text("\(viewModel.myRecipes.count) created")
                .font(.merriweather(14, weight: .regular))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 16)
    }
    
    private var gridSection: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(viewModel.myRecipes, id: \.title) { recipe in
                NavigationLink(destination: RecipeDetailView(recipe: recipe, viewModel: viewModel)) {
                    RecipeCardView(recipe: recipe, viewModel: viewModel)
                }
                .buttonStyle(PlainButtonStyle())
                .contextMenu {
                    if viewModel.isOwner(recipe: recipe) {
                        Button { recipeToEdit = recipe } label: { Label("Edit Recipe", systemImage: "pencil") }
                        Button(role: .destructive) {
                            recipeToDelete = recipe
                            showingDeleteAlert = true
                        } label: { Label("Delete Recipe", systemImage: "trash") }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 120)
    }
    
    private var floatingActionButton: some View {
        Button(action: { showingCreateSheet = true }) {
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

// MARK: - Collection Selection Bottom Sheet
struct CollectionSelectionSheet: View {
    @ObservedObject var viewModel: RecipeViewModel
    
    // Theme Colors
    let burntOrange = Color(hex: "cd4b12")
    let mutedTeal = Color(hex: "43766c")
    let bgYellow = Color(hex: "f8fae5")
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                
                // 1. Daftar Koleksi
                List(viewModel.userCollections, id: \.id) { collection in
                    Button(action: {
                        if let id = collection.id {
                            // Animasi agar centang terasa responsif
                            withAnimation(.easeInOut(duration: 0.15)) {
                                viewModel.toggleCollectionSelection(collectionId: id)
                            }
                        }
                    }) {
                        HStack(spacing: 12) {
                            if let id = collection.id, viewModel.selectedCollectionIds.contains(id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(burntOrange)
                                    .font(.system(size: 22))
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray.opacity(0.5))
                                    .font(.system(size: 22))
                            }
                            
                            Text(collection.name)
                                .font(.merriweather(16, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .contentShape(Rectangle()) // Area tap lebih besar
                    }
                    .padding(.vertical, 8)
                }
                .listStyle(.plain)
                .padding(.bottom, 80) // Ruang bernapas agar tidak tertutup tombol Save
                
                // 2. Tombol Save di bagian bawah
                if !viewModel.userCollections.isEmpty {
                    Button(action: {
                        Task { await viewModel.saveToSelectedCollections() }
                    }) {
                        Text(viewModel.isSavingToCollections ? "Saving..." : "Save (\(viewModel.selectedCollectionIds.count))")
                            .font(.merriweather(16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(viewModel.selectedCollectionIds.isEmpty || viewModel.isSavingToCollections ? .gray : mutedTeal)
                            .cornerRadius(16)
                            .padding(.horizontal, 20)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: -2)
                    }
                    .disabled(viewModel.selectedCollectionIds.isEmpty || viewModel.isSavingToCollections)
                    .padding(.bottom, 16)
                }
            }
            .navigationTitle("Save to Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { viewModel.showCollectionSheet = false }
                        .foregroundColor(burntOrange)
                        .font(.merriweather(16, weight: .bold))
                }
            }
            .overlay {
                if viewModel.isSavingToCollections {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    ProgressView().tint(.white).scaleEffect(1.5)
                } else if viewModel.userCollections.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 48))
                            .foregroundColor(mutedTeal.opacity(0.5))
                        Text("You don't have any collections yet.")
                            .font(.merriweather(14))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Preview Mock Data Extension
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

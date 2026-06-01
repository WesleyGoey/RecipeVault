//
//  MyRecipesView.swift
//  RecipeVault
//
//  Created by Nicholas Gerwin Mawardji on 29/05/26.
//

import SwiftUI

// MARK: - My Recipes Main View
struct MyRecipesView: View {
    // TERIMA BINDING TAB & RESET LOGIC
    @Binding var selectedTab: Int
    @State private var navResetID = UUID()
    
    // 🚀 1. Injeksi ViewModel Autentikasi dan Profil
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var profileVM = ProfileViewModel()
    @StateObject private var viewModel = RecipeViewModel()
    
    // UI States
    @State private var showingCreateSheet = false
    @State private var recipeToEdit: Recipe? = nil
    @State private var recipeToDelete: Recipe? = nil
    @State private var showingDeleteAlert = false
    
    // 🚀 2. State untuk mengontrol kemunculan halaman Login/Register
    @State private var showAuthView = false
    @State private var authInitialMode: AuthMode = .login
    
    private let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
    
    // Theme Colors
    let bgYellow = Color(hex: "f8fae5")
    let mutedTeal = Color(hex: "43766c")
    let burntOrange = Color(hex: "cd4b12")
    let darkText = Color.primary
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                bgYellow.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        headerSection
                        
                        // 🚀 3. LOGIKA PENGECEKAN LOGIN DENGAN AUTHVM
                        if !authVM.isLoggedIn {
                            unauthenticatedArea
                        } else {
                            if viewModel.myRecipes.isEmpty {
                                emptyStateView
                            } else {
                                gridSection
                            }
                        }
                    }
                }
                
                // 🚀 4. Sembunyikan tombol + jika belum login
                if authVM.isLoggedIn {
                    floatingActionButton
                }
            }
            .navigationBarHidden(true)
            .task {
                // Saat layar dibuka, tarik data (jika login)
                if authVM.isLoggedIn {
                    await profileVM.initializeUserProfile()
                    
                    if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                        viewModel.myRecipes = Recipe.previewMockData
                    } else {
                        await viewModel.loadMyRecipes()
                    }
                }
            }
            // 🚀 5. PANTAU LOGOUT/LOGIN SECARA REAL-TIME
            .onChange(of: authVM.isLoggedIn) { isLoggedIn in
                if isLoggedIn {
                    // Jika baru login, muat data
                    Task {
                        await profileVM.initializeUserProfile()
                        await viewModel.loadMyRecipes()
                    }
                } else {
                    // Jika logout, bersihkan layar secara instan
                    viewModel.myRecipes.removeAll()
                    profileVM.userId = ""
                }
            }
            
            // 🚀 INJEKSI VIEWMODEL KE SHEET LOGIN
            .sheet(isPresented: $showAuthView) {
                AuthView(vm: profileVM, initialMode: authInitialMode)
            }
            .sheet(isPresented: $viewModel.showCollectionSheet) {
                CollectionSelectionSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $showingCreateSheet) {
                RecipeCreateView(viewModel: viewModel)
            }
            .sheet(item: $recipeToEdit) { recipe in
                RecipeEditView(recipeToEdit: recipe, viewModel: viewModel)
            }
            .alert("Delete Recipe", isPresented: $showingDeleteAlert, presenting: recipeToDelete) { recipe in
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task { await viewModel.deleteRecipe(recipe: recipe) }
                }
            } message: { recipe in
                Text("Are you sure you want to delete '\(recipe.title)'? This action cannot be undone.")
            }
            .alert("Terjadi Kesalahan", isPresented: Binding(
                get: { !viewModel.operationError.isEmpty },
                set: { if !$0 { viewModel.operationError = "" } }
            )) {
                Button("OK", role: .cancel) { viewModel.operationError = "" }
            } message: {
                Text(viewModel.operationError)
            }
        }
        .id(navResetID) // RESET LOGIC
        .onChange(of: selectedTab) { newTab in
            // Jika keluar dari tab MyRecipes (index 2), reset halamannya!
            if newTab != 2 {
                navResetID = UUID()
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
                .foregroundColor(darkText)
            
            if authVM.isLoggedIn {
                Text("\(viewModel.myRecipes.count) created")
                    .font(.merriweather(14, weight: .regular))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 16)
    }
    
    // 🚀 TAMPILAN JIKA USER BELUM LOGIN
    private var unauthenticatedArea: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 40)
            
            Image(systemName: "lock.rectangle.stack")
                .font(.system(size: 60))
                .foregroundColor(mutedTeal.opacity(0.5))
            
            Text("Login Required")
                .font(.merriweather(24, weight: .bold))
                .foregroundColor(darkText)
            
            Text("In order to view and create your personal recipes, you need to log in or register first.")
                .font(.merriweather(15, weight: .regular))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            HStack(spacing: 12) {
                Button(action: {
                    authInitialMode = .login
                    showAuthView = true
                }) {
                    Text("Login")
                        .font(.merriweather(16, weight: .bold))
                        .frame(minWidth: 120, maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .foregroundColor(Color(hex: "2F6B5E"))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "EDEFE3"), lineWidth: 1))
                }

                Button(action: {
                    authInitialMode = .register
                    showAuthView = true
                }) {
                    Text("Register")
                        .font(.merriweather(16, weight: .bold))
                        .frame(minWidth: 120, maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(hex: "2F6B5E"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .frame(maxWidth: 420)
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .frame(maxWidth: .infinity)
    }
    
    // 🚀 TAMPILAN JIKA RESEP KOSONG
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(mutedTeal.opacity(0.4))
            
            Text("No Recipes Yet")
                .font(.merriweather(24, weight: .bold))
                .foregroundColor(darkText)
            
            Text("Start creating your own personal recipes by tapping the + button.")
                .font(.merriweather(14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
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
        )
    ]
}

// MARK: - Preview
#Preview {
    MyRecipesView(selectedTab: .constant(2))
        .environmentObject(AuthViewModel()) // Wajib untuk preview
}

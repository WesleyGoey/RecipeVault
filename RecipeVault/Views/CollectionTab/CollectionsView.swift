//
//  CollectionsView.swift
//  RecipeVault
//
//  Created by Nicholas Gerwin Mawardji on 29/05/26.
//

import SwiftUI

struct CollectionsView: View {
    // 🚀 1. Injeksi ViewModel Autentikasi dan Profil
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var profileVM = ProfileViewModel()
    
    @StateObject private var viewModel = CollectionViewModel()
    
    @State private var showingCreateSheet = false
    @State private var collectionToEdit: RecipeCollection? = nil
    @State private var collectionToDelete: RecipeCollection? = nil
    @State private var showingDeleteAlert = false
    
    // 🚀 2. State untuk mengontrol kemunculan halaman Login/Register
    @State private var showAuthView = false
    @State private var authInitialMode: AuthMode = .login
    
    let bgYellow = Color(hex: "f8fae5")
    let mutedTeal = Color(hex: "43766c")
    let burntOrange = Color(hex: "cd4b12")
    let darkText = Color.primary
    
    let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
    
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
                            if viewModel.myCollections.isEmpty {
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
                // Saat layar dibuka, tarik profil (jika login)
                if authVM.isLoggedIn {
                    await profileVM.initializeUserProfile()
                    
                    if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                        viewModel.myCollections = RecipeCollection.mockCollections
                    } else {
                        await viewModel.loadMyCollections()
                    }
                }
            }
            // 🚀 5. PANTAU LOGOUT/LOGIN SECARA REAL-TIME
            .onChange(of: authVM.isLoggedIn) { isLoggedIn in
                if isLoggedIn {
                    // Jika baru login, muat data
                    Task {
                        await profileVM.initializeUserProfile()
                        await viewModel.loadMyCollections()
                    }
                } else {
                    // Jika logout, bersihkan layar secara instan
                    viewModel.myCollections.removeAll()
                    profileVM.userId = ""
                }
            }
            // 🚀 INJEKSI VIEWMODEL KE SHEET LOGIN
            .sheet(isPresented: $showAuthView) {
                AuthView(vm: profileVM, initialMode: authInitialMode)
            }
            .sheet(isPresented: $showingCreateSheet) {
                CollectionCreateView(viewModel: viewModel)
            }
            .sheet(item: $collectionToEdit) { collection in
                CollectionEditView(collectionToEdit: collection, viewModel: viewModel)
            }
            .alert("Delete Collection", isPresented: $showingDeleteAlert, presenting: collectionToDelete) { collection in
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task { await viewModel.deleteCollection(collection: collection) }
                }
            } message: { collection in
                Text("Are you sure you want to delete '\(collection.name)'? Recipes inside will not be deleted.")
            }
        }
    }
}

// MARK: - Subviews
extension CollectionsView {
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("My Collections")
                .font(.merriweather(36, weight: .bold)) // 🚀 FONT
                .foregroundColor(darkText)
            
            // Filter controls (Hanya relevan jika user login)
            if authVM.isLoggedIn {
                HStack {
                    Button(action: {}) {
                        Label("Alphabetical", systemImage: "arrow.up.arrow.down").font(.merriweather(14, weight: .bold)).foregroundColor(darkText)
                    }
                    Spacer()
                    Button(action: {}) { Image(systemName: "square.grid.2x2").font(.system(size: 20)).foregroundColor(darkText) }
                }
            }
        }
        .padding(.horizontal, 20).padding(.top, 24).padding(.bottom, 16)
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
            
            Text("In order to view and create your personal collections, you need to log in or register first.")
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
    
    private var gridSection: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(viewModel.myCollections, id: \.name) { collection in
                let recipeCount = viewModel.collectionCounts[collection.id ?? ""] ?? 0
                
                NavigationLink(destination: CollectionDetailView(collection: collection, viewModel: viewModel)) {
                    CollectionCardView(collection: collection, recipeCount: recipeCount)
                }
                .buttonStyle(PlainButtonStyle())
                .contextMenu {
                    if viewModel.isOwner(collection: collection) {
                        Button { collectionToEdit = collection } label: { Label("Edit Collection", systemImage: "pencil") }
                        Button(role: .destructive) {
                            collectionToDelete = collection
                            showingDeleteAlert = true
                        } label: { Label("Delete Collection", systemImage: "trash") }
                    }
                }
            }
        }.padding(.horizontal, 20).padding(.bottom, 120)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.grid.2x2.fill")
                .font(.system(size: 64))
                .foregroundColor(mutedTeal.opacity(0.4))
            
            Text("No Collections Yet")
                .font(.merriweather(24, weight: .bold))
                .foregroundColor(darkText)
            
            Text("Organize your favorite recipes into custom folders. Tap the + button to create one.")
                .font(.merriweather(14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
    
    private var floatingActionButton: some View {
        Button(action: { showingCreateSheet = true }) {
            Image(systemName: "plus").font(.system(size: 24, weight: .semibold)).foregroundColor(.white)
                .frame(width: 64, height: 64).background(mutedTeal).clipShape(Circle()).shadow(color: mutedTeal.opacity(0.3), radius: 8, x: 0, y: 4)
        }.padding(.trailing, 20).padding(.bottom, 24)
    }
}

// MARK: - Preview
#Preview {
    CollectionsView()
        .environmentObject(AuthViewModel())
}

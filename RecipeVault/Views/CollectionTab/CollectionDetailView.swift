//
//  CollectionDetailView.swift
//  RecipeVault
//
//  Created by Wesley Goey on 29/05/26.
//

import SwiftUI

struct CollectionDetailView: View {
    let collection: RecipeCollection
    @ObservedObject var viewModel: CollectionViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    // Theme Colors
    let bgYellow = Color(hex: "f8fae5")
    let mutedTeal = Color(hex: "43766c")
    let burntOrange = Color(hex: "cd4b12")
    let darkText = Color.primary
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                heroImageSection
                
                VStack(alignment: .leading, spacing: 20) {
                    headerInfoSection
                    authorSection
                    
                    // 🚀 Deskripsi langsung di sini (Tanpa Tabs)
                    Text(collection.description)
                        .font(.custom("Merriweather-Regular", size: 15))
                        .foregroundColor(.gray)
                        .lineSpacing(4)
                        .padding(.top, -8)
                    
                    Text("Recipes (\(viewModel.recipesInCollection.count))")
                        .font(.custom("Merriweather-Bold", size: 20))
                        .padding(.top, 10)
                    
                    recipesListSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(bgYellow.ignoresSafeArea())
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .task {
            // Load resep saat view dibuka
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                viewModel.recipesInCollection = Recipe.mockRecipes
            } else {
                guard let id = collection.id else { return }
                await viewModel.loadRecipesForCollection(collectionId: id)
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            Text("Edit Sheet for \(collection.name)")
        }
        .alert("Delete Collection", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteCollection(collection: collection)
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to delete this collection?")
        }
    }
}

// MARK: - Subviews
extension CollectionDetailView {
    
    private var heroImageSection: some View {
        ZStack(alignment: .top) {
            Color.clear
                .frame(height: 320)
                .overlay(
                    AsyncImage(url: URL(string: collection.collectionImage)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Rectangle().fill(Color.gray.opacity(0.3)).overlay(ProgressView())
                    }
                )
                .clipped()
                .overlay(LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.7)]), startPoint: .center, endPoint: .bottom))
            
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.black.opacity(0.4))
                        .clipShape(Circle())
                }
                Spacer()
                if viewModel.isOwner(collection: collection) {
                    Menu {
                        Button { showingEditSheet = true } label: { Label("Edit Collection", systemImage: "pencil") }
                        Button(role: .destructive) { showingDeleteAlert = true } label: { Label("Delete Collection", systemImage: "trash") }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.top, 50)
            .padding(.horizontal, 20)
            
            // Text Over Image Overlay
            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                HStack {
                    Image(systemName: collection.visibility == .publicVisibility ? "globe" : "lock.fill")
                    Text(collection.visibility.rawValue.uppercased())
                }
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(mutedTeal.opacity(0.8))
                .clipShape(Capsule())
                
                Text(collection.name)
                    .font(.custom("Merriweather-Bold", size: 32))
                    .foregroundColor(.white)
                
                Text("\(viewModel.recipesInCollection.count) recipes")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var headerInfoSection: some View {
        EmptyView() // Ruang ini digantikan oleh teks di atas gambar
    }
    
    private var authorSection: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(mutedTeal)
                .frame(width: 46, height: 46)
                .overlay(Text("ME").font(.system(size: 14, weight: .bold)).foregroundColor(.white))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("You").font(.headline).fontWeight(.bold)
                Text("Your collection").font(.subheadline).foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundColor(.gray)
        }
        .padding(.vertical, 10)
    }
    
    private var recipesListSection: some View {
        LazyVStack(spacing: 16) {
            ForEach(viewModel.recipesInCollection, id: \.title) { recipe in
                // 🚀 Custom List Row Sesuai Screenshot Detail
                HStack(spacing: 16) {
                    AsyncImage(url: URL(string: recipe.recipeImage)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(recipe.title)
                            .font(.custom("Merriweather-Bold", size: 16))
                            .foregroundColor(darkText)
                            .lineLimit(1)
                        
                        HStack(spacing: 8) {
                            Text(recipe.category)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10).padding(.vertical, 4)
                                .background(burntOrange).clipShape(Capsule())
                            
                            // Placeholder Cooking Time karena dihapus dari model
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                Text("30 min")
                            }
                            .font(.caption)
                            .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                    Image(systemName: "chevron.right").foregroundColor(.gray.opacity(0.5))
                }
                .padding(12)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
            }
        }
    }
}

#Preview {
    CollectionDetailView(collection: RecipeCollection.mockCollections[0], viewModel: CollectionViewModel())
}

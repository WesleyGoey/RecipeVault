//
//  CollectionDetailView.swift
//  RecipeVault
//
//  Created by Nicholas Gerwin Mawardji on 29/05/26.
//

import SwiftUI
import FirebaseFirestore

struct CollectionDetailView: View {
    let collection: RecipeCollection
    @ObservedObject var viewModel: CollectionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false

    @State private var creatorName: String = "Loading..."

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
                    authorSection

                    Text(collection.description.isEmpty ? "Tidak ada deskripsi." : collection.description)
                        .font(.merriweather(15, weight: .regular))
                        .foregroundColor(.gray)
                        .lineSpacing(4)
                        .padding(.top, -8)

                    Text("Recipes (\(viewModel.recipesInCollection.count))")
                        .font(.merriweather(20, weight: .bold))
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
            // Ambil daftar resep untuk koleksi ini
            if let collectionId = collection.id {
                await viewModel.loadRecipesForCollection(collectionId: collectionId)
            }
        }
    }
}

// MARK: - Subviews
extension CollectionDetailView {
    
    private var heroImageSection: some View {
        ZStack(alignment: .top) {
            
            if collection.collectionImage.isEmpty {
                ZStack {
                    mutedTeal.opacity(0.15)
                    Image(systemName: "folder.fill").font(.system(size: 60)).foregroundColor(mutedTeal.opacity(0.5))
                }
                .frame(height: 300).frame(maxWidth: .infinity).clipped()
            }
            else if collection.collectionImage.starts(with: "http") {
                AsyncImage(url: URL(string: collection.collectionImage.trimmingCharacters(in: .whitespacesAndNewlines))) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else if phase.error != nil {
                        ZStack {
                            mutedTeal.opacity(0.15)
                            Image(systemName: "folder.fill").font(.system(size: 60)).foregroundColor(mutedTeal.opacity(0.5))
                        }
                    } else {
                        ZStack {
                            mutedTeal.opacity(0.15)
                            ProgressView()
                        }
                    }
                }
                .frame(height: 300).frame(maxWidth: .infinity).clipped()
            }
            else if let imageData = Data(base64Encoded: collection.collectionImage),
                    let uiImage = UIImage(data: imageData) {
                
                Color.clear.overlay(
                    Image(uiImage: uiImage).resizable().scaledToFill()
                )
                .frame(height: 300).frame(maxWidth: .infinity).clipped()
                
            } else {
                ZStack {
                    mutedTeal.opacity(0.15)
                    Image(systemName: "folder.fill").font(.system(size: 60)).foregroundColor(mutedTeal.opacity(0.5))
                }
                .frame(height: 300).frame(maxWidth: .infinity).clipped()
            }
            
            LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.6)]), startPoint: .center, endPoint: .bottom)
                .frame(height: 300)
            
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
            }
            .padding(.top, 50).padding(.horizontal, 20)
        }
    }
    
    private var authorSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(collection.name)
                    .font(.merriweather(28, weight: .bold))
                    .foregroundColor(darkText)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 6) {
                    Image(systemName: collection.visibility == .publicVisibility ? "globe" : "lock.fill")
                    Text(collection.visibility.rawValue.capitalized)
                }
                .font(.merriweather(12, weight: .regular))
                .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(.top, 4)
    }
    
    private var recipesListSection: some View {
        VStack(spacing: 16) {
            if viewModel.isLoading {
                ProgressView().padding(.top, 40)
            } else if viewModel.recipesInCollection.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 40))
                        .foregroundColor(mutedTeal.opacity(0.3))
                    Text("No recipes here yet.")
                        .font(.merriweather(14))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
            } else {
                ForEach(viewModel.recipesInCollection) { recipe in
                    
                    // 🚀 BUNGKUS DENGAN NAVIGATION LINK AGAR BISA DITAP KE RECIPEDETAILVIEW
                    NavigationLink(destination: RecipeDetailView(recipe: recipe, viewModel: RecipeViewModel())) {
                        HStack(spacing: 16) {
                            
                            // Thumbnail Recipe
                            ZStack {
                                if recipe.recipeImage.isEmpty {
                                    mutedTeal.opacity(0.15)
                                    Image(systemName: "fork.knife").foregroundColor(mutedTeal.opacity(0.5))
                                }
                                // 🚀 LOGIKA BARU: SUPPORT GAMBAR HTTP (THEMEALDB) DI DALAM LIST
                                else if recipe.recipeImage.starts(with: "http") {
                                    AsyncImage(url: URL(string: recipe.recipeImage.trimmingCharacters(in: .whitespacesAndNewlines))) { phase in
                                        if let image = phase.image {
                                            image.resizable().scaledToFill()
                                        } else {
                                            mutedTeal.opacity(0.15)
                                            Image(systemName: "fork.knife").foregroundColor(mutedTeal.opacity(0.5))
                                        }
                                    }
                                }
                                else if let imageData = Data(base64Encoded: recipe.recipeImage),
                                          let uiImg = UIImage(data: imageData) {
                                    Image(uiImage: uiImg).resizable().scaledToFill()
                                } else {
                                    mutedTeal.opacity(0.15)
                                    Image(systemName: "fork.knife").foregroundColor(mutedTeal.opacity(0.5))
                                }
                            }
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(recipe.title)
                                    .font(.merriweather(16, weight: .bold))
                                    .foregroundColor(darkText)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                                Text(recipe.category)
                                    .font(.merriweather(12))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray.opacity(0.5))
                        }
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

#Preview {
    CollectionDetailView(
        collection: RecipeCollection.mockCollections[0],
        viewModel: CollectionViewModel()
    )
}

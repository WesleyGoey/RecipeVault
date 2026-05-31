//
//  RecipeCardView.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//

import SwiftUI

struct RecipeCardView: View {
    
    // MARK: - Properties
    let recipe: Recipe
    
    // INJEKSI VIEWMODEL UNTUK MENGAKSES FUNGSI FAVORITE & COLLECTION
    @ObservedObject var viewModel: RecipeViewModel
    
    // Theme Colors
    let burntOrange = Color(hex: "cd4b12")
    let mutedTeal = Color(hex: "43766c")
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            imageSection
            infoSection
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Subviews
extension RecipeCardView {
    
    // MARK: - Image Section & Placeholder
    private var imageSection: some View {
        Group {
            // 1. JIKA GAMBAR KOSONG
            if recipe.recipeImage.isEmpty {
                placeholderImage
            }
            // 🚀 2. JIKA BERUPA URL (Data dari TheMealDB)
            else if recipe.recipeImage.starts(with: "http") {
                AsyncImage(url: URL(string: recipe.recipeImage.trimmingCharacters(in: .whitespacesAndNewlines))) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else if phase.error != nil {
                        placeholderImage
                    } else {
                        // Sedang loading
                        ZStack {
                            mutedTeal.opacity(0.15)
                            ProgressView()
                        }
                    }
                }
            }
            // 🚀 3. JIKA BERUPA BASE64 (Data buatan User dari Firebase)
            else if let imageData = Data(base64Encoded: recipe.recipeImage),
                    let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            // 4. FALLBACK JIKA SEMUA GAGAL
            else {
                placeholderImage
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 150)
        .clipped() // Mencegah gambar meluap keluar dari batas 150
    }
    
    // Tampilan garpu pisau default yang diekstrak agar tidak berulang
    private var placeholderImage: some View {
        ZStack {
            mutedTeal.opacity(0.15)
            Image(systemName: "fork.knife")
                .font(.system(size: 40))
                .foregroundColor(mutedTeal.opacity(0.5))
        }
    }
    
    // MARK: - Info Section
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(recipe.title)
                // 🚀 Font Fix menggunakan extension-mu
                .font(.merriweather(16, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(minHeight: 40, alignment: .topLeading)
            
            HStack(spacing: 12) {
                Spacer()
                
                // TOMBOL ADD TO COLLECTION
                Button(action: {
                    Task { await viewModel.openCollectionSheet(for: recipe) }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(burntOrange)
                        .padding(10)
                        .background(burntOrange.opacity(0.15))
                        .clipShape(Circle())
                }
                
                // TOMBOL FAVORITE DENGAN LOGIKA NYATA
                let isFav = viewModel.isFavorite(recipe: recipe)
                Button(action: {
                    Task { await viewModel.toggleFavorite(recipe: recipe) }
                }) {
                    Image(systemName: isFav ? "heart.fill" : "heart")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(isFav ? .white : burntOrange)
                        .padding(10)
                        .background(isFav ? burntOrange : burntOrange.opacity(0.15))
                        .clipShape(Circle())
                        .shadow(color: isFav ? burntOrange.opacity(0.3) : .clear, radius: 6, x: 0, y: 3)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color(hex: "f8fae5").ignoresSafeArea()
        
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
            
            // 1. Kartu DENGAN Gambar URL (TheMealDB)
            RecipeCardView(
                recipe: Recipe(
                    userId: "themealdb",
                    title: "Spicy Arrabiata",
                    description: "",
                    ingredients: [],
                    steps: [],
                    category: "Vegetarian",
                    recipeImage: "https://www.themealdb.com/images/media/meals/ustsqw1468250014.jpg"
                ),
                viewModel: RecipeViewModel()
            )
            
            // 2. Kartu TANPA Gambar (Fallback)
            RecipeCardView(
                recipe: Recipe(
                    userId: "123",
                    title: "Mom's Secret Recipe",
                    description: "",
                    ingredients: [],
                    steps: [],
                    category: "Secret",
                    recipeImage: "" // Sengaja dikosongkan
                ),
                viewModel: RecipeViewModel()
            )
        }
        .padding(20)
    }
}

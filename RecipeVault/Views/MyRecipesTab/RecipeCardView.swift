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
            // JIKA GAMBAR KOSONG: Tampilkan Placeholder Garpu Pisau Elegan
            if recipe.recipeImage.isEmpty {
                ZStack {
                    mutedTeal.opacity(0.15)
                    Image(systemName: "fork.knife")
                        .font(.system(size: 40))
                        .foregroundColor(mutedTeal.opacity(0.5))
                }
            }
            // 🚀 DECODE BASE64 LANGSUNG
            else if let imageData = Data(base64Encoded: recipe.recipeImage),
                    let uiImage = UIImage(data: imageData) {
                
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                
            } else {
                // FALLBACK JIKA BASE64 CORRUPT/GAGAL DIBACA
                ZStack {
                    mutedTeal.opacity(0.15)
                    Image(systemName: "fork.knife")
                        .font(.system(size: 40))
                        .foregroundColor(mutedTeal.opacity(0.5))
                }
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 150)
        .clipped() // Mencegah gambar meluap keluar dari batas 150
    }
    
    // MARK: - Info Section
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(recipe.title)
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
            
            // 1. Kartu DENGAN Gambar (Mock Asli)
            RecipeCardView(
                recipe: Recipe.previewMockData[0],
                viewModel: RecipeViewModel()
            )
            
            // 2. Kartu TANPA Gambar (Modifikasi Mock instan)
            RecipeCardView(
                recipe: {
                    var mock = Recipe.previewMockData[1]
                    mock.recipeImage = "" // Sengaja dikosongkan
                    return mock
                }(),
                viewModel: RecipeViewModel()
            )
        }
        .padding(20)
    }
}

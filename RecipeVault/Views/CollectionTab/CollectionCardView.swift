//
//  CollectionCardView.swift
//  RecipeVault
//
//  Created by Nicholas Gerwin Mawardji on 29/05/26.
//

import SwiftUI

struct CollectionCardView: View {
    // 🚀 Menggunakan model RecipeCollection
    let collection: RecipeCollection
    var recipeCount: Int = 0 // 🚀 Tambahan parameter jumlah resep
    
    // Theme Colors
    let darkText = Color.primary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Gambar Koleksi
            Color.clear
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    AsyncImage(url: URL(string: collection.collectionImage)) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .overlay(ProgressView())
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .overlay(Image(systemName: "photo").foregroundColor(.gray))
                        @unknown default:
                            EmptyView()
                        }
                    }
                )
                .clipped() // 🚀 Tambahkan ini agar aman
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
            
            // Teks Info Koleksi
            VStack(alignment: .leading, spacing: 4) {
                Text(collection.name)
                    .font(.merriweather(16, weight: .bold))
                    .foregroundColor(darkText)
                    .lineLimit(1)
                
                // 🚀 Mengganti "Collection • You" menjadi Visibilitas dan Jumlah Resep
                let visibilityText = collection.visibility == .publicVisibility ? "Public" : "Private"
                Text("\(visibilityText) • \(recipeCount) \(recipeCount == 1 ? "Recipe" : "Recipes")")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 4)
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color(hex: "f8fae5").ignoresSafeArea()
        
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            CollectionCardView(
                collection: RecipeCollection(
                    userId: "123",
                    name: "Weeknight Favorites",
                    description: "Quick dinners",
                    collectionImage: "https://images.unsplash.com/photo-1556910103-1c02745aae4d?q=80&w=500&auto=format&fit=crop",
                    visibility: .publicVisibility
                ),
                recipeCount: 5 // 🚀 Contoh data preview
            )
        }
        .padding(20)
    }
}

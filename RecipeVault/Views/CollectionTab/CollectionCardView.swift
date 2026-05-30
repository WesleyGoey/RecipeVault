//
//  CollectionCardView.swift
//  RecipeVault
//
//  Created by Nicholas Gerwin Mawardji on 29/05/26.
//

import SwiftUI

struct CollectionCardView: View {
    let collection: RecipeCollection
    var recipeCount: Int = 0
    
    let darkText = Color.primary
    let mutedTeal = Color(hex: "43766c")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // MARK: - Kotak Gambar (Isolasi total agar tidak tembus)
            ZStack {
                // Background solid agar tidak transparan
                Color.white
                
                if collection.collectionImage.isEmpty {
                    mutedTeal.opacity(0.15)
                    Image(systemName: "square.stack.fill")
                        .font(.system(size: 40))
                        .foregroundColor(mutedTeal.opacity(0.5))
                } else {
                    AsyncImage(url: URL(string: collection.collectionImage)) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            mutedTeal.opacity(0.15)
                            Image(systemName: "square.stack.fill").foregroundColor(mutedTeal.opacity(0.5))
                        }
                    }
                }
            }
            .frame(height: 140) // Kunci tinggi agar rapi di grid
            .frame(maxWidth: .infinity)
            .clipped() // Memotong apapun yang meluap dari kotak 140
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // MARK: - Teks Info (Di luar ZStack gambar)
            VStack(alignment: .leading, spacing: 4) {
                Text(collection.name)
                    .font(.merriweather(16, weight: .bold))
                    .foregroundColor(darkText)
                    .lineLimit(1)
                
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
        // Warna background layar kuning
        Color(hex: "f8fae5").ignoresSafeArea()
        
        // 🚀 PREVIEW MENAMPILKAN 2 KARTU (DENGAN GAMBAR & TANPA GAMBAR)
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            
            // 1. Kartu DENGAN Gambar
            CollectionCardView(
                collection: RecipeCollection(
                    userId: "123",
                    name: "Weeknight Favorites",
                    description: "Quick dinners",
                    collectionImage: "https://images.unsplash.com/photo-1556910103-1c02745aae4d?q=80&w=500&auto=format&fit=crop",
                    visibility: .publicVisibility
                ),
                recipeCount: 5
            )
            
            // 2. Kartu TANPA Gambar (Ikon tidak akan tembus)
            CollectionCardView(
                collection: RecipeCollection(
                    userId: "123",
                    name: "Secret Recipes",
                    description: "My secret formulas",
                    collectionImage: "", // Kosong untuk tes Ikon
                    visibility: .privateVisibility
                ),
                recipeCount: 12
            )
        }
        .padding(20)
    }
}

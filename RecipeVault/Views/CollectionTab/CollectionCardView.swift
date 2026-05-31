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
            
            // MARK: - Kotak Gambar (Membaca Base64)
            ZStack {
                // Background solid agar tidak transparan
                Color.white
                
                if collection.collectionImage.isEmpty {
                    mutedTeal.opacity(0.15)
                    Image(systemName: "square.stack.fill")
                        .font(.system(size: 40))
                        .foregroundColor(mutedTeal.opacity(0.5))
                }
                // 🚀 BACA TEKS BASE64 LANGSUNG
                else if let imageData = Data(base64Encoded: collection.collectionImage),
                        let uiImage = UIImage(data: imageData) {
                    
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        
                } else {
                    // Fallback jika data corrupt
                    mutedTeal.opacity(0.15)
                    Image(systemName: "square.stack.fill")
                        .font(.system(size: 40))
                        .foregroundColor(mutedTeal.opacity(0.5))
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
        
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            
            // 1. Kartu DENGAN Gambar (Mock data tidak punya base64 asli, jadi akan fallback ke Ikon otomatis)
            CollectionCardView(
                collection: RecipeCollection.mockCollections[0],
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

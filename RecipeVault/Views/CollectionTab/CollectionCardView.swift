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
    
    // Theme Colors
    let darkText = Color.primary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Gambar Koleksi (Rasio 1:1 agar responsif sempurna di grid)
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
                                .aspectRatio(contentMode: .fill) // Mengisi seluruh kotak
                        case .failure:
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .overlay(Image(systemName: "photo").foregroundColor(.gray))
                        @unknown default:
                            EmptyView()
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
            
            // Teks Info Koleksi
            VStack(alignment: .leading, spacing: 4) {
                Text(collection.name)
                    .font(.merriweather(16, weight: .bold))
                    .foregroundColor(darkText)
                    .lineLimit(1) // Maksimal 1 baris agar rapi
                
                // Statis "You" sesuai desain UI
                Text("Collection • You")
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
            CollectionCardView(collection: RecipeCollection(
                userId: "123",
                name: "Weeknight Favorites",
                description: "Quick dinners",
                collectionImage: "https://images.unsplash.com/photo-1556910103-1c02745aae4d?q=80&w=500&auto=format&fit=crop",
                visibility: .publicVisibility
            ))
        }
        .padding(20)
    }
}

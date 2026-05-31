//
//  FeedCardView.swift
//  RecipeVault
//
//  Created by Nicholas Gerwin Mawardji on 29/05/26.
//

import SwiftUI

struct FeedCardView: View {
    let recipe: Recipe
    // Parameter tinggi agar bisa diatur dinamis (untuk efek Zig-Zag)
    var cardHeight: CGFloat = 240
    
    let burntOrange = Color(hex: "cd4b12")
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            
            // 1. Background Image
            GeometryReader { geo in
                AsyncImage(url: URL(string: recipe.recipeImage)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle().fill(Color.gray.opacity(0.3)).overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                            .clipped()
                    case .failure:
                        Rectangle().fill(Color.gray.opacity(0.3)).overlay(Image(systemName: "photo").foregroundColor(.gray))
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            
            // 2. Dark Gradient Overlay
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.1), .black.opacity(0.85)]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // 3. Text Content
            VStack(alignment: .leading, spacing: 10) {
                Text(recipe.title)
                    .font(.merriweather(18, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(recipe.category)
                    .font(.merriweather(12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(burntOrange)
                    .clipShape(Capsule())
            }
            .padding(16)
        }
        .frame(height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        // Menggunakan warna background cream khas RecipeVault
        Color(hex: "FBF9EC").ignoresSafeArea()
        
        ScrollView {
            // Simulasi Staggered Grid (Zig-Zag Effect) dengan 2 Kolom
            HStack(alignment: .top, spacing: 16) {
                
                // --- KOLOM KIRI ---
                VStack(spacing: 16) {
                    FeedCardView(
                        recipe: Recipe(
                            userId: "123",
                            title: "Blueberry Pavlova",
                            description: "Kue meringue renyah dengan topping berry melimpah.",
                            ingredients: [], steps: [],
                            category: "Dessert",
                            recipeImage: "https://images.unsplash.com/photo-1464305795204-6f5bbfc7fb81?q=80&w=500&auto=format&fit=crop"
                        ),
                        cardHeight: 280 // 🚀 Lebih Tinggi
                    )
                    
                    FeedCardView(
                        recipe: Recipe(
                            userId: "123",
                            title: "Classic Creamy Ramen",
                            description: "Mi kuah kaldu kental gurih ala Kopitiam.",
                            ingredients: [], steps: [],
                            category: "Noodles",
                            recipeImage: "https://images.unsplash.com/photo-1569718212165-3a8278d5f624?q=80&w=500&auto=format&fit=crop"
                        ),
                        cardHeight: 200 // 🚀 Lebih Pendek
                    )
                }
                
                // --- KOLOM KANAN ---
                VStack(spacing: 16) {
                    FeedCardView(
                        recipe: Recipe(
                            userId: "123",
                            title: "Mom's Sunday Pasta",
                            description: "Resep pasta turun temurun hari minggu.",
                            ingredients: [], steps: [],
                            category: "Italian",
                            recipeImage: "https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?q=80&w=500&auto=format&fit=crop"
                        ),
                        cardHeight: 210 // 🚀 Lebih Pendek
                    )
                    
                    FeedCardView(
                        recipe: Recipe(
                            userId: "123",
                            title: "Lemon Herb Roast Chicken",
                            description: "Ayam panggang juicy dengan perasan lemon segar.",
                            ingredients: [], steps: [],
                            category: "Dinner",
                            recipeImage: "https://images.unsplash.com/photo-1598103442097-8b74394b98c6?q=80&w=500&auto=format&fit=crop"
                        ),
                        cardHeight: 300 // 🚀 Lebih Tinggi
                    )
                }
            }
            .padding(16)
        }
    }
}

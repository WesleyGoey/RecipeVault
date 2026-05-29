//
//  HomeCardView.swift
//  RecipeVault
//
//  Created by Nicholas Gerwin Mawardji on 29/05/26.
//


import SwiftUI

struct HomeCardView: View {
    let recipe: Recipe
    
    // Theme Colors
    let burntOrange = Color(hex: "cd4b12")
    let bgYellow = Color(hex: "f8fae5") // Digunakan untuk memberikan sedikit warna kekuningan pada teks "RECIPE OF THE DAY"
    
    var body: some View {
        ZStack {
            // 1. Background Image
            AsyncImage(url: URL(string: recipe.recipeImage)) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(Image(systemName: "photo").foregroundColor(.gray))
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 320)
            .frame(maxWidth: .infinity)
            .clipped()
            
            // 2. Gradient Overlay (Gelap di bawah agar teks putih terlihat jelas)
            LinearGradient(
                gradient: Gradient(colors: [
                    .clear,
                    .black.opacity(0.3),
                    .black.opacity(0.85)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // 3. Content Overlay
            VStack {
                // Top-Left Badge ("🔥 FEATURED")
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                        Text("FEATURED")
                            .font(.custom("Merriweather-Bold", size: 12))
                            .tracking(1.0) // Jarak antar huruf
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(burntOrange)
                    .clipShape(Capsule())
                    
                    Spacer()
                }
                
                Spacer()
                
                // Bottom Center Texts
                VStack(spacing: 8) {
                    Text("RECIPE OF THE DAY")
                        .font(.custom("Merriweather-Bold", size: 12))
                        .tracking(2.0)
                        .foregroundColor(bgYellow.opacity(0.9))
                    
                    Text(recipe.title)
                        .font(.custom("Merriweather-Bold", size: 32))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 16)
                }
                .padding(.bottom, 16)
            }
            .padding(20)
        }
        .frame(height: 320)
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color(hex: "43766c").ignoresSafeArea() // Background gelap untuk preview
        
        HomeCardView(
            recipe: Recipe(
                userId: "123",
                title: "Braised Short Ribs",
                description: "A classic dish.",
                ingredients: [],
                steps: [],
                category: "Beef",
                recipeImage: "https://images.unsplash.com/photo-1544025162-8315ea070940?q=80&w=2938&auto=format&fit=crop"
            )
        )
        .padding()
    }
}
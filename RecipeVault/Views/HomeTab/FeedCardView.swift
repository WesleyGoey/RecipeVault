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

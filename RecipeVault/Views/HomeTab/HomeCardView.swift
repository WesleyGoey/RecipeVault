//
//  HomeCardView.swift
//  RecipeVault
//
//  Created by Nicholas Gerwin Mawardji on 29/05/26.
//

import SwiftUI

// MARK: - Home Card
struct HomeCardView: View {
    let recipe: Recipe
    @EnvironmentObject var recipeVM: RecipeViewModel
    
    let burntOrange = Color(hex: "cd4b12")
    let mutedTeal = Color(hex: "43766c")
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color.clear
                .overlay(imageSection)
                .clipped()
            
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                startPoint: .center,
                endPoint: .bottom
            )
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Spacer()
                    favoriteButton
                }
                Spacer()
                
                Text("RECIPE OF THE DAY")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(burntOrange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.white)
                    .clipShape(Capsule())
                
                Text(recipe.title)
                    .font(.merriweather(24, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 320)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Home Card Subviews & Logic
extension HomeCardView {
    // MARK: - Favorite Button with Real Logic
    private var favoriteButton: some View {
        let isFav = recipeVM.isFavorite(recipe: recipe)
        return Button(action: {
            Task { await recipeVM.toggleFavorite(recipe: recipe) }
        }) {
            Image(systemName: isFav ? "heart.fill" : "heart")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(isFav ? .white : burntOrange)
                .padding(12)
                .background(isFav ? burntOrange : Color.white.opacity(0.9))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
    // MARK: - Image Handling with Multiple Sources
    private var imageSection: some View {
        Group {
            if recipe.recipeImage.isEmpty {
                placeholderImage
            } else if recipe.recipeImage.starts(with: "http") {
                AsyncImage(url: URL(string: recipe.recipeImage.trimmingCharacters(in: .whitespacesAndNewlines))) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else if phase.error != nil {
                        placeholderImage
                    } else {
                        ZStack {
                            mutedTeal.opacity(0.15)
                            ProgressView()
                        }
                    }
                }
            } else if let imageData = Data(base64Encoded: recipe.recipeImage),
                      let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage).resizable().aspectRatio(contentMode: .fill)
            } else {
                placeholderImage
            }
        }
    }
    
    // MARK: - Image Placeholder for Missing or Failed Images
    private var placeholderImage: some View {
        ZStack {
            mutedTeal.opacity(0.15)
            Image(systemName: "fork.knife")
                .font(.system(size: 60))
                .foregroundColor(mutedTeal.opacity(0.5))
        }
    }
}

#Preview {
    HomeCardView(recipe: Recipe(userId: "1", title: "Test Recipe", description: "", ingredients: [], steps: [], category: "Dessert", recipeImage: ""))
        .environmentObject(RecipeViewModel())
}

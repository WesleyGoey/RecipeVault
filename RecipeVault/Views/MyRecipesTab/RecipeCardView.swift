//
//  RecipeCardView.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//

import SwiftUI

// MARK: - Recipe Card View
struct RecipeCardView: View {
    let recipe: Recipe
    
    @ObservedObject var viewModel: RecipeViewModel
    
    let burntOrange = Color(hex: "cd4b12")
    let mutedTeal = Color(hex: "43766c")
    
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
            if recipe.recipeImage.isEmpty {
                placeholderImage
            }
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
            else if let imageData = Data(base64Encoded: recipe.recipeImage),
                    let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            else {
                placeholderImage
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 150)
        .clipped()
    }
    
    // MARK: - Placeholder Image For Missing/Invalid URLs
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
                .font(.merriweather(16, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(minHeight: 40, alignment: .topLeading)
            
            HStack(spacing: 12) {
                Spacer()
                
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
            
            RecipeCardView(
                recipe: Recipe(
                    userId: "123",
                    title: "Mom's Secret Recipe",
                    description: "",
                    ingredients: [],
                    steps: [],
                    category: "Secret",
                    recipeImage: ""
                ),
                viewModel: RecipeViewModel()
            )
        }
        .padding(20)
    }
}

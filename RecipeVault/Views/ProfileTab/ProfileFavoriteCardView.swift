//
//  ProfileFavoriteCardView.swift
//  RecipeVault
//
//  Created by Wesley Goey on 31/05/26.
//

import SwiftUI
import FirebaseAuth

// MARK: - Profile Favorite Card View
struct ProfileFavoriteCardView: View {
    let recipe: Recipe
    
    @ObservedObject var recipeVM: RecipeViewModel
    @ObservedObject var profileVM: ProfileViewModel
    
    @State private var authorName: String = "Loading..."
    
    let burntOrange = Color(hex: "cd4b12")
    let darkText = Color.primary
    let mutedTeal = Color(hex: "43766c")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                Group {
                    let imageUrl = recipe.recipeImage.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if imageUrl.isEmpty {
                        ZStack {
                            mutedTeal.opacity(0.15)
                            Image(systemName: "fork.knife")
                                .font(.system(size: 30))
                                .foregroundColor(mutedTeal.opacity(0.5))
                        }
                    }
                    else if imageUrl.starts(with: "http") {
                        AsyncImage(url: URL(string: imageUrl)) { phase in
                            switch phase {
                            case .empty:
                                Rectangle().fill(Color.gray.opacity(0.15)).overlay(ProgressView())
                            case .success(let image):
                                image.resizable().scaledToFill()
                            case .failure:
                                ZStack {
                                    mutedTeal.opacity(0.15)
                                    Image(systemName: "fork.knife")
                                        .font(.system(size: 30))
                                        .foregroundColor(mutedTeal.opacity(0.5))
                                }
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                    else if let imageData = Data(base64Encoded: imageUrl),
                            let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    }
                    else {
                        ZStack {
                            mutedTeal.opacity(0.15)
                            Image(systemName: "fork.knife")
                                .font(.system(size: 30))
                                .foregroundColor(mutedTeal.opacity(0.5))
                        }
                    }
                }
                .frame(height: 140)
                .frame(maxWidth: .infinity)
                .clipped()
                
                Button(action: { Task { await recipeVM.toggleFavorite(recipe: recipe) } }) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 18))
                        .foregroundColor(burntOrange)
                        .padding(10)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                }
                .padding(12)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(recipe.title)
                    .font(.merriweather(16, weight: .bold))
                    .foregroundColor(darkText)
                    .lineLimit(2)
                    .frame(minHeight: 40, alignment: .topLeading)
                
                Text(authorName == "TheMealDB" || authorName == "Me" ? "by \(authorName)" : "by \(authorName)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(burntOrange)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 16)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .contentShape(Rectangle())
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        
        .task {
            self.authorName = await profileVM.fetchAuthorName(for: recipe.userId)
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color(hex: "f8fae5").ignoresSafeArea()
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ProfileFavoriteCardView(
                recipe: Recipe(
                    userId: "themealdb",
                    title: "Thai Green Curry",
                    description: "Authentic thai green curry.",
                    ingredients: [],
                    steps: [],
                    category: "Thai",
                    recipeImage: "" 
                ),
                recipeVM: RecipeViewModel(),
                profileVM: ProfileViewModel()
            )
        }
        .padding(20)
    }
}

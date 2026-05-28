//
//  RecipeCardView.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


// MARK: - RecipeCardView
import SwiftUI

struct RecipeCardView: View {
    
    // MARK: - Properties
    let recipe: Recipe
    
    // Theme Colors
    let burntOrange = Color(hex: "cd4b12")
    
    // MARK: - Body
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
    
    private var imageSection: some View {
        AsyncImage(url: URL(string: recipe.recipeImage)) { phase in
            switch phase {
            case .empty:
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay(ProgressView())
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay(Image(systemName: "photo").foregroundColor(.gray))
            @unknown default:
                EmptyView()
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 150)
        .clipped()
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(recipe.title)
                .font(.custom("Merriweather-Bold", size: 16, relativeTo: .headline))
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(minHeight: 40, alignment: .topLeading)
            
            // 🚀 Revisi: Mengganti Kategori menjadi Waktu Masak & Porsi
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                    Text("\(recipe.cookingTime) min")
                }
                
                Text("·")
                    .fontWeight(.bold)
                
                Text("\(recipe.servings) \(recipe.servings == 1 ? "serving" : "servings")")
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color(hex: "f8fae5").ignoresSafeArea()
        
        RecipeCardView(recipe: Recipe(
            userId: "user123",
            title: "Mom's Sunday Pasta",
            description: "Classic family recipe.",
            ingredients: [], steps: [], category: "Italian",
            recipeImage: "https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?q=80&w=500&auto=format&fit=crop",
            cookingTime: 30, servings: 2
        ))
        .frame(width: 170)
    }
}


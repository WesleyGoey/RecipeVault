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

// MARK: - Local Color Extension
fileprivate extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue:  Double(b) / 255, opacity: Double(a) / 255)
    }
}

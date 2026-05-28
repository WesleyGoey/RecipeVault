//
//  RecipeCardView.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


//
//  RecipeCardView.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//  Modified by Sean Tandjaja for Action Buttons alignment.
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
    
    // MARK: - Image Section
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
    
    // MARK: - Info Section
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(recipe.title)
                .font(.custom("Merriweather-Bold", size: 16, relativeTo: .headline))
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(minHeight: 40, alignment: .topLeading)
            
            // 🚀 Revisi: Kategori dihapus, diganti Tombol Aksi Kustom sepadan dengan DetailView
            HStack(spacing: 12) {
                Spacer()
                
                // Tombol Plus (Gaya Bulat Transent ala RecipeDetailView)
                Button(action: {
                    // TODO: Pemicu Bottom Sheet multi-select koleksi (Tugas Teman)
                    print("Plus button tapped for: \(recipe.title)")
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(burntOrange)
                        .padding(10)
                        .background(burntOrange.opacity(0.15))
                        .clipShape(Circle())
                }
                
                // Tombol Heart (Gaya Bulat Solid ala RecipeDetailView)
                Button(action: {
                    // TODO: Pemicu logika atomik favorit toggle (Tugas Teman)
                    print("Favorite button tapped for: \(recipe.title)")
                }) {
                    Image(systemName: "heart")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(burntOrange)
                        .clipShape(Circle())
                        .shadow(color: burntOrange.opacity(0.3), radius: 6, x: 0, y: 3)
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
        Color(hex: "f8fae5").ignoresSafeArea() // bgYellow
        
        // Simulasi Grid di Halaman utama/pencarian
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
            RecipeCardView(recipe: Recipe(
                userId: "user123",
                title: "Lemon Herb Roast Chicken",
                description: "A delicious and juicy roast chicken.",
                ingredients: ["Chicken", "Lemon"],
                steps: ["Roast it."],
                category: "Dinner",
                recipeImage: "https://images.unsplash.com/photo-1598103442097-8b74394b98c6?q=80&w=500&auto=format&fit=crop"
            ))
            
            RecipeCardView(recipe: Recipe(
                userId: "user123",
                title: "Mom's Sunday Pasta",
                description: "Classic family recipe.",
                ingredients: ["Pasta"],
                steps: ["Boil it."],
                category: "Italian",
                recipeImage: "https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?q=80&w=500&auto=format&fit=crop"
            ))
        }
        .padding(20)
    }
}

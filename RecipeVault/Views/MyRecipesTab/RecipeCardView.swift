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
        // Menggunakan RoundedRectangle dengan corner radius besar sesuai desain
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Subviews
extension RecipeCardView {
    
    private var imageSection: some View {
        // Solusi: Menggunakan GeometryReader / frame terkontrol agar AsyncImage mematuhi lebar kolom Grid
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
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            @unknown default:
                EmptyView()
            }
        }
        // Menghapus maxWidth .infinity yang tidak terkontrol pada level image murni
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 150) // 🚀 Membatasi tinggi gambar secara tegas agar pas di grid 2 kolom
        .clipped() // Memotong sisa gambar yang meluap keluar batas frame
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(recipe.title)
                .font(.custom("Merriweather-Bold", size: 16, relativeTo: .headline)) // Ukuran font disesuaikan menjadi 16 agar pas untuk 2 kolom
                .foregroundColor(.primary)
                .lineLimit(2) // Maksimal 2 baris agar layout tidak rusak jika judul terlalu panjang
                .multilineTextAlignment(.leading)
                // Memaksa tinggi minimum agar sejajar di grid meskipun judul hanya 1 baris
                .frame(minHeight: 40, alignment: .topLeading)
            
            Text(recipe.category)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(burntOrange)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color(hex: "f8fae5").ignoresSafeArea() // bgYellow
        
        ScrollView {
            // Simulasi Grid 2 Kolom di halaman My Recipes
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                
                // Kartu 1 (Data dari desain)
                RecipeCardView(recipe: Recipe(
                    userId: "user123",
                    title: "Lemon Herb Roast Chicken",
                    description: "A delicious and juicy roast chicken.",
                    ingredients: ["Chicken", "Lemon", "Herbs"],
                    steps: ["Roast in oven."],
                    category: "Dinner",
                    recipeImage: "https://www.themealdb.com/images/media/meals/1529446358.jpg",
                    cookingTime: 45,
                    servings: 4
                ))
                
                // Kartu 2 (Judul pendek untuk menguji alignment frame)
                RecipeCardView(recipe: Recipe(
                    userId: "user123",
                    title: "Mom's Sunday Pasta",
                    description: "Classic family recipe.",
                    ingredients: ["Pasta", "Tomato Sauce"],
                    steps: ["Boil water."],
                    category: "Italian",
                    recipeImage: "https://www.themealdb.com/images/media/meals/sutysw1468247559.jpg",
                    cookingTime: 30,
                    servings: 2
                ))
            }
            .padding(20)
        }
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

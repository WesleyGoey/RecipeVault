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
    @State private var displayImage: String = ""
    
    let burntOrange = Color(hex: "cd4b12")
    let darkText = Color.primary
    let mutedTeal = Color(hex: "43766c")
    
    var body: some View {
        // 🚀 KUNCI PERBAIKAN: ZStack Utama untuk memisahkan area klik Kartu dan Tombol Hati
        ZStack(alignment: .topTrailing) {
            
            // 1. AREA KARTU (BISA DIKLIK UNTUK MASUK KE DETAIL)
            NavigationLink(destination: RecipeDetailView(recipe: recipe, viewModel: recipeVM)) {
                VStack(alignment: .leading, spacing: 12) {
                    Group {
                        let imageUrl = displayImage.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        if imageUrl.isEmpty {
                            placeholderView
                        }
                        else if imageUrl.starts(with: "http") {
                            AsyncImage(url: URL(string: imageUrl)) { phase in
                                switch phase {
                                case .empty:
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.15))
                                        .overlay(ProgressView())
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                case .failure(_):
                                    placeholderView
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
                            placeholderView
                        }
                    }
                    .frame(height: 140)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(recipe.title)
                            .font(.merriweather(16, weight: .bold))
                            .foregroundColor(darkText)
                            .lineLimit(2)
                            .frame(minHeight: 40, alignment: .topLeading)
                        
                        Text("by \(authorName)")
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
            }
            .buttonStyle(PlainButtonStyle()) // Mencegah teks menjadi warna biru bawaan iOS
            
            // 2. TOMBOL HEART (MELAYANG BEBAS DI ATAS NAVIGATION LINK)
            Image(systemName: "heart.fill")
                .font(.system(size: 18))
                .foregroundColor(burntOrange)
                .padding(10)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                .padding(12) // Posisikan di pojok
                .contentShape(Circle()) // Batasi area sentuh agar presisi
                .highPriorityGesture(
                    TapGesture().onEnded {
                        // 🚀 OPTIMISTIC UI UPDATE:
                        // Hapus langsung dari layar secara visual agar pengguna merasa aplikasi sangat cepat!
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            profileVM.favoriteRecipes.removeAll { $0.id == recipe.id }
                        }
                        
                        // Proses penghapusan asli di database Firebase berjalan di latar belakang
                        Task {
                            await recipeVM.toggleFavorite(recipe: recipe)
                        }
                    }
                )
        }
        .task {
            self.displayImage = recipe.recipeImage
            self.authorName = await profileVM.fetchAuthorName(for: recipe.userId)
            
            // Auto-fallback TheMealDB
            if displayImage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && recipe.userId == "themealdb", let mealId = recipe.id {
                guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(mealId)") else { return }
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let meals = json["meals"] as? [[String: Any]],
                       let fullMeal = meals.first,
                       let mealThumb = fullMeal["strMealThumb"] as? String {
                        await MainActor.run {
                            withAnimation {
                                self.displayImage = mealThumb
                            }
                        }
                    }
                } catch {
                    print("Gagal mengambil gambar pemulihan otomatis: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private var placeholderView: some View {
        ZStack {
            mutedTeal.opacity(0.15)
            Image(systemName: "fork.knife")
                .font(.system(size: 30))
                .foregroundColor(mutedTeal.opacity(0.5))
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

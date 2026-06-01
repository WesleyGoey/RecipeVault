//
//  DiscoveryCardView.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 28/05/26.
//

import SwiftUI

struct DiscoverCardView: View {
    // MARK: - Properties (Parameter agar kartu bisa dipakai berulang)
    var title: String
    var author: String
    var recipeCount: Int
    var imageUrl: String?
    var badgeText: String = "COLLECTION"
    
    // Theme Colors
    let mutedTeal = Color(hex: "43766c")
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            backgroundSection
            
            gradientOverlay
            
            badgeSection
            
            textContentSection
        }
        .frame(height: 240)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        // 🚀 Memastikan seluruh kartu padat dan bisa ditekan di NavigationLink
        .contentShape(Rectangle())
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Subviews
extension DiscoverCardView {
    
    // 🚀 PERBAIKAN: Menambahkan dukungan Base64 untuk gambar dari Firebase
    private var backgroundSection: some View {
        Group {
            let urlStr = (imageUrl ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            
            if urlStr.isEmpty {
                placeholderView
            } else if urlStr.starts(with: "http") {
                AsyncImage(url: URL(string: urlStr)) { phase in
                    switch phase {
                    case .empty:
                        placeholderView
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        placeholderView
                    @unknown default:
                        placeholderView
                    }
                }
                .frame(height: 240)
                .frame(maxWidth: .infinity)
                .clipped()
            } else if let imageData = Data(base64Encoded: urlStr),
                      let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 240)
                    .frame(maxWidth: .infinity)
                    .clipped()
            } else {
                placeholderView
            }
        }
    }
    
    private var gradientOverlay: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                .clear,
                .black.opacity(0.2),
                .black.opacity(0.85) // Sedikit lebih gelap di bawah untuk kontras teks putih
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var badgeSection: some View {
        VStack {
            HStack {
                Text(badgeText.uppercased())
                    .font(.system(size: 11, weight: .bold, design: .default))
                    .tracking(1.5) // Memberikan jarak antar huruf (letter spacing)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(mutedTeal)
                    .clipShape(Capsule())
                
                Spacer() // Mendorong badge ke kiri
            }
            Spacer() // Mendorong badge ke atas
        }
        .padding(20)
    }
    
    private var textContentSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(author.uppercased())
                // 🚀 Menggunakan extension Merriweather
                .font(.merriweather(11, weight: .bold))
                .tracking(1.2)
                .foregroundColor(.white.opacity(0.9))
            
            Text(title)
                // 🚀 Menggunakan extension Merriweather
                .font(.merriweather(24, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(2) // Maksimal 2 baris agar layout tidak rusak jika judul panjang
            
            Text("\(recipeCount) recipes curated")
                // 🚀 Menggunakan extension Merriweather
                .font(.merriweather(14, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(20)
    }
    
    private var placeholderView: some View {
        ZStack {
            Color(hex: "e2e6c8") // Sedikit lebih gelap dari bgYellow sebagai background placeholder
            
            // TODO: Ganti "fork.knife" dengan Image("NamaAsetTopiKokiKamu") jika sudah ada aset kustom
            Image(systemName: "fork.knife")
                .font(.system(size: 40))
                .foregroundColor(mutedTeal.opacity(0.4))
        }
        .frame(height: 240)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview with Dummy Data
#Preview {
    VStack(spacing: 20) {
        // Contoh 1: Menggunakan URL Gambar Asli (seperti di Figma)
        DiscoverCardView(
            title: "Quick Weeknight Dinners",
            author: "@CHEF_MARIA",
            recipeCount: 24,
            imageUrl: "https://images.unsplash.com/photo-1556910103-1c02745aae4d?q=80&w=2940&auto=format&fit=crop"
        )
        
        DiscoverCardView(
            title: "Baking Essentials",
            author: "@BAKE_WITH_LOVE",
            recipeCount: 31,
            imageUrl: nil
        )
    }
    .padding()
    .background(Color(hex: "f8fae5").ignoresSafeArea())
}

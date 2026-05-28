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
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Subviews
extension DiscoverCardView {
    
    private var backgroundSection: some View {
        Group {
            if let urlString = imageUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
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
                .font(.custom("Merriweather-Bold", size: 11))
                .tracking(1.2)
                .foregroundColor(.white.opacity(0.9))
            
            Text(title)
                .font(.custom("Merriweather-Bold", size: 24))
                .foregroundColor(.white)
                .lineLimit(2) // Maksimal 2 baris agar layout tidak rusak jika judul panjang
            
            Text("\(recipeCount) recipes curated")
                .font(.custom("Merriweather-Regular", size: 14))
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

// MARK: - Local Color Extension (Menghindari Invalid Redeclaration)
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

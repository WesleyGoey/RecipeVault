//
//  ColourPallette.swift
//  RecipeVault
//
//  Created by Wesley Goey on 14/05/26.
//

import SwiftUI

struct ColourPallette: View {
    // 3 Warna Utama yang Diinginkan
    let backgroundCream = Color(hex: "#f8fae5")
    let primaryGreen = Color(hex: "#43766c")
    let accentOrange = Color(hex: "#cd4b12")
    
    // Warna Tambahan untuk UI
    let pageBackground = Color(hex: "#F4F1EA")
    let neutralNavy = Color(hex: "#2B3A4A")

    var body: some View {
        ZStack {
            pageBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    
                    // Header
                    Text("RecipeApp Design System")
                        .font(.custom("Merriweather-Bold", size: 18))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 10)

                    // 1. TYPOGRAPHY HIERARCHY
                    VStack(alignment: .leading, spacing: 20) {
                        Text("1. TYPOGRAPHY HIERARCHY")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.secondary)
                        
                        typographySection(label: "Large Title (34pt)", font: "Merriweather-Bold", size: 34)
                        typographySection(label: "Headline (17pt)", font: "Merriweather-Bold", size: 17)
                        typographySection(label: "Body Text (17pt)", font: "Merriweather-Regular", size: 17)
                    }

                    // 2. COLOR PALETTE (Hanya 3 Warna Utama)
                    VStack(alignment: .leading, spacing: 20) {
                        Text("2. COLOR PALETTE")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 20) {
                            colorSwatch(color: backgroundCream, label: "Background", hex: "#F8FAE5")
                            colorSwatch(color: primaryGreen, label: "Primary", hex: "#43766C")
                            colorSwatch(color: accentOrange, label: "Accent", hex: "#CD4B12")
                        }
                    }

                    // 3. BUTTON STANDARDS
                    VStack(alignment: .leading, spacing: 15) {
                        Text("3. BUTTON STANDARDS")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.secondary)
                        
                        // Tombol Menggunakan Primary Green
                        standardButton(text: "Save Recipe", icon: "plus.circle.fill", color: primaryGreen)
                        
                        // Tombol Menggunakan Neutral Navy (Sesuai request)
                        standardButton(text: "Explore Recipes", icon: "magnifyingglass", color: neutralNavy)
                        
                        // Tombol Menggunakan Accent Orange
                        standardButton(text: "Delete Draft", icon: "trash.fill", color: accentOrange)
                    }
                }
                .padding(25)
            }
        }
    }

    // --- Helper Functions ---
    
    @ViewBuilder
    func typographySection(label: String, font: String, size: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.custom(font, size: size))
            Text("\(font.replacingOccurrences(of: "-", with: " "))")
                .font(.caption).foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    func colorSwatch(color: Color, label: String, hex: String) -> some View {
        VStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 70, height: 70) // Sedikit lebih besar karena warnanya hanya 3
                .shadow(color: .black.opacity(0.1), radius: 3, y: 2)
            VStack(spacing: 2) {
                Text(label).font(.system(size: 10, weight: .bold))
                Text(hex).font(.system(size: 9)).foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder
    func standardButton(text: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
            Text(text)
                .font(.custom("Merriweather-Bold", size: 16))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color)
        .foregroundColor(.white)
        .cornerRadius(15)
    }
}

// Extension untuk Hex Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6: (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default: (r, g, b) = (0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: 1)
    }
}

#Preview {
    ColourPallette()
}

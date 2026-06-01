//
//  DiscoveryCardView.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 28/05/26.
//

import SwiftUI

// MARK: - Discover Card View
struct DiscoverCardView: View {
    var title: String
    var author: String
    var recipeCount: Int
    var imageUrl: String?
    var badgeText: String = "COLLECTION"
    
    var isCompact: Bool = false
    
    let mutedTeal = Color(hex: "43766c")
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            backgroundSection
            gradientOverlay
            badgeSection
            textContentSection
        }
        .frame(height: 240)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .contentShape(Rectangle())
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Extension For Discovery Card Subviews
extension DiscoverCardView {
    private var backgroundSection: some View {
        let urlStr = (imageUrl ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        return Color.clear
            .overlay(
                Group {
                    if urlStr.isEmpty {
                        placeholderView
                    } else if urlStr.starts(with: "http") {
                        AsyncImage(url: URL(string: urlStr)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                placeholderView
                            }
                        }
                    } else if let imageData = Data(base64Encoded: urlStr), let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        placeholderView
                    }
                }
            )
            .frame(height: 240)
            .clipped()
    }
    
    // MARK: - Gradient Overlay For Better Text Readability
    private var gradientOverlay: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                .clear,
                .black.opacity(0.2),
                .black.opacity(0.85)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Badge Section
    private var badgeSection: some View {
        VStack {
            HStack {
                Text(badgeText.uppercased())
                    .font(.system(size: isCompact ? 9 : 11, weight: .bold, design: .default))
                    .tracking(1.5)
                    .foregroundColor(.white)
                    .padding(.horizontal, isCompact ? 10 : 16)
                    .padding(.vertical, isCompact ? 6 : 8)
                    .background(mutedTeal)
                    .clipShape(Capsule())
                
                Spacer(minLength: 0)
            }
            Spacer(minLength: 0)
        }
        .padding(isCompact ? 12 : 20)
    }
    
    // MARK: - Text Content Section (Author, Title, Recipe Count)
    private var textContentSection: some View {
        VStack(alignment: .leading, spacing: isCompact ? 4 : 6) {
            Text(author.uppercased())
                .font(.merriweather(isCompact ? 9 : 11, weight: .bold))
                .tracking(1.2)
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(1)
            
            Text(title)
                .font(.merriweather(isCompact ? 16 : 24, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            
            Text("\(recipeCount) recipes curated")
                .font(.merriweather(isCompact ? 11 : 14, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(1)
        }
        .padding(isCompact ? 12 : 20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Placeholder View For Missing/Invalid Images
    private var placeholderView: some View {
        ZStack {
            Color(hex: "e2e6c8")
            
            Image(systemName: "fork.knife")
                .font(.system(size: 40))
                .foregroundColor(mutedTeal.opacity(0.4))
        }
        .frame(height: 240)
        .frame(maxWidth: .infinity)
    }
}

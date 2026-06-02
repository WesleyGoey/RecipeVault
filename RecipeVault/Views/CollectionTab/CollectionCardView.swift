//
//  CollectionCardView.swift
//  RecipeVault
//
//  Created by Nicholas Gerwin Mawardji on 29/05/26.
//

import SwiftUI

// MARK: - Collection Card View
struct CollectionCardView: View {
    let collection: RecipeCollection
    var recipeCount: Int = 0
    
    let darkText = Color.primary
    let mutedTeal = Color(hex: "43766c")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                Color.white
                
                if collection.collectionImage.isEmpty {
                    mutedTeal.opacity(0.15)
                    Image(systemName: "square.stack.fill")
                        .font(.system(size: 40))
                        .foregroundColor(mutedTeal.opacity(0.5))
                }
                else if let imageData = Data(base64Encoded: collection.collectionImage),
                        let uiImage = UIImage(data: imageData) {
                    
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        
                } else {
                    mutedTeal.opacity(0.15)
                    Image(systemName: "square.stack.fill")
                        .font(.system(size: 40))
                        .foregroundColor(mutedTeal.opacity(0.5))
                }
            }
            .frame(height: 140)
            .frame(maxWidth: .infinity)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(collection.name)
                    .font(.merriweather(16, weight: .bold))
                    .foregroundColor(darkText)
                    .lineLimit(1)
                
                let visibilityText = collection.visibility == .publicVisibility ? "Public" : "Private"
                Text("\(visibilityText) • \(recipeCount) \(recipeCount == 1 ? "Recipe" : "Recipes")")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 4)
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color(hex: "f8fae5").ignoresSafeArea()
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            
            CollectionCardView(
                collection: RecipeCollection.mockCollections[0],
                recipeCount: 5
            )
            
            CollectionCardView(
                collection: RecipeCollection(
                    userId: "123",
                    name: "Secret Recipes",
                    description: "My secret formulas",
                    collectionImage: "", 
                    visibility: .privateVisibility
                ),
                recipeCount: 12
            )
        }
        .padding(20)
    }
}

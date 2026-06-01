//
//  ProfileCollectionCardView.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 01/06/26.
//

import SwiftUI

// MARK: - Profile Collection Card View
struct ProfileCollectionCardView: View {
    let collection: RecipeCollection
    let recipeCount: Int
    var placeholderColors: [Color] = [Color(hex: "F3E9C9"), Color(hex: "E6D8B7")]

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Group {
                let imageUrl = collection.collectionImage.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if imageUrl.isEmpty {
                    placeholderView
                } else if imageUrl.starts(with: "http") {
                    AsyncImage(url: URL(string: imageUrl)) { phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                placeholderView
                                ProgressView()
                            }
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipped()
                        case .failure:
                            placeholderView
                        @unknown default:
                            placeholderView
                        }
                    }
                } else if let imageData = Data(base64Encoded: imageUrl),
                          let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                } else {
                    placeholderView
                }
            }
            .frame(height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                VStack {
                    HStack {
                        if collection.visibility == .publicVisibility {
                            Label {
                                Text("PUBLIC")
                                    .font(.caption2).bold()
                            } icon: {
                                Image(systemName: "globe")
                                    .font(.caption2).bold()
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 8)
                            .background(Color(hex: "2F6B5E"))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(8)
                        } else {
                            Label {
                                Text("PRIVATE")
                                    .font(.caption2).bold()
                            } icon: {
                                Image(systemName: "lock.fill")
                                    .font(.caption2).bold()
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 8)
                            .background(Color.gray.opacity(0.9))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(8)
                        }
                        Spacer()
                    }
                    Spacer()
                }
            )
            .overlay(alignment: .topTrailing) {
                Text("\(recipeCount)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.black.opacity(0.55))
                    .clipShape(Circle())
                    .padding(10)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Spacer()
                Text(collection.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "163A2B"))
                    .lineLimit(1)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .offset(y: 12)
            }
            .padding(.horizontal, 0)
        }
        .background(Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .contentShape(Rectangle())
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
    }
    
    // MARK: - Placeholder View For Empty or Invalid Images
    private var placeholderView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(LinearGradient(colors: placeholderColors, startPoint: .topLeading, endPoint: .bottomTrailing))
            Image(systemName: "square.stack.fill")
                .font(.system(size: 44))
                .foregroundColor(Color(hex: "163A2B").opacity(0.15))
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color(hex: "FBF9EC").ignoresSafeArea()
        ProfileCollectionCardView(
            collection: RecipeCollection(
                userId: "u1",
                name: "Weeknight Favorites",
                description: "Tasty easy dinners",
                collectionImage: "", 
                visibility: .publicVisibility
            ),
            recipeCount: 7
        )
        .frame(width: 170, height: 140)
        .padding()
    }
}

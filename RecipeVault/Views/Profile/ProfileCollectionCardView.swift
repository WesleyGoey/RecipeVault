//
// CollectionCardView.swift
// RecipeVault
//

import SwiftUI

struct ProfileCollectionCardView: View {
    let collection: RecipeCollection
    let recipeCount: Int
    var placeholderColors: [Color] = [Color(hex: "F3E9C9"), Color(hex: "E6D8B7")]

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Group {
                if let url = URL(string: collection.collectionImage), !collection.collectionImage.isEmpty {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(LinearGradient(colors: placeholderColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipped()
                        case .failure:
                            RoundedRectangle(cornerRadius: 14)
                                .fill(LinearGradient(colors: placeholderColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                        @unknown default:
                            RoundedRectangle(cornerRadius: 14)
                                .fill(LinearGradient(colors: placeholderColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                        }
                    }
                } else {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(LinearGradient(colors: placeholderColors, startPoint: .topLeading, endPoint: .bottomTrailing))
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
                        }
                        Spacer()
                    }
                    Spacer()
                }
            )

            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Text("\(recipeCount)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.55))
                        .clipShape(Circle())
                        .padding(10)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Spacer()
                Text(collection.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "163A2B"))
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
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
    }
}

#if DEBUG
struct CollectionCardView_Previews: PreviewProvider {
    static var previews: some View {
        let sample = RecipeCollection(
            id: "c1",
            userId: "u1",
            name: "Weeknight Favorites",
            description: "Tasty easy dinners",
            collectionImage: "",
            visibility: .publicVisibility,
            createdAt: nil
        )
        VStack {
            ProfileCollectionCardView(collection: sample, recipeCount: 7)
                .frame(width: 170, height: 140)
                .padding()
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif

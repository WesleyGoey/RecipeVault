//
//  ProfileCollectionCardView.swift
//  RecipeVault
//

import SwiftUI

struct ProfileCollectionCardView: View {
    let collection: RecipeCollection
    let recipeCount: Int
    var placeholderColors: [Color] = [Color(hex: "F3E9C9"), Color(hex: "E6D8B7")]

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // MARK: - Background Image / Placeholder
            Group {
                if collection.collectionImage.isEmpty {
                    // 🚀 JIKA GAMBAR KOSONG: Tampilkan Icon Folder Elegan
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(LinearGradient(colors: placeholderColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                        Image(systemName: "square.stack.fill")
                            .font(.system(size: 44))
                            .foregroundColor(Color(hex: "163A2B").opacity(0.15)) // Warna hijau gelap transparan
                    }
                } else if let url = URL(string: collection.collectionImage) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(LinearGradient(colors: placeholderColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                                ProgressView()
                            }
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipped()
                        case .failure:
                            // 🚀 JIKA GAGAL LOAD: Tampilkan Icon Folder
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(LinearGradient(colors: placeholderColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                                Image(systemName: "square.stack.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(Color(hex: "163A2B").opacity(0.15))
                            }
                        @unknown default:
                            RoundedRectangle(cornerRadius: 14)
                                .fill(LinearGradient(colors: placeholderColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                        }
                    }
                }
            }
            .frame(height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            
            // MARK: - Overlays (Pills & Count)
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
                            // Tambahan untuk Private (opsional)
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

            // Recipe Count Pill
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

            // Collection Name Banner
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
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
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
                collectionImage: "", // Kosong untuk mengetes Icon
                visibility: .publicVisibility
            ),
            recipeCount: 7
        )
        .frame(width: 170, height: 140)
        .padding()
    }
}

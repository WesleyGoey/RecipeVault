import SwiftUI

struct FeedCardView: View {
    let recipe: Recipe
    let cardHeight: CGFloat
    @EnvironmentObject var recipeVM: RecipeViewModel
    
    let burntOrange = Color(hex: "cd4b12")
    let mutedTeal = Color(hex: "43766c")
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                
                // 🚀 KUNCI PERBAIKAN: Sama seperti HomeCardView
                Color.clear
                    .overlay(imageSection)
                    .clipped()
                    .frame(height: cardHeight - 75)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.title)
                        .font(.merriweather(14, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(recipe.category)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(height: 75, alignment: .topLeading)
            }
            
            favoriteButton
                .padding(10)
        }
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

extension FeedCardView {
    private var favoriteButton: some View {
        let isFav = recipeVM.isFavorite(recipe: recipe)
        return Button(action: {
            Task { await recipeVM.toggleFavorite(recipe: recipe) }
        }) {
            Image(systemName: isFav ? "heart.fill" : "heart")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(isFav ? .white : burntOrange)
                .padding(10)
                .background(isFav ? burntOrange : Color.white.opacity(0.9))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
    
    private var imageSection: some View {
        Group {
            if recipe.recipeImage.isEmpty {
                placeholderImage
            } else if recipe.recipeImage.starts(with: "http") {
                AsyncImage(url: URL(string: recipe.recipeImage.trimmingCharacters(in: .whitespacesAndNewlines))) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else if phase.error != nil {
                        placeholderImage
                    } else {
                        ZStack {
                            mutedTeal.opacity(0.15)
                            ProgressView()
                        }
                    }
                }
            } else if let imageData = Data(base64Encoded: recipe.recipeImage),
                      let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage).resizable().aspectRatio(contentMode: .fill)
            } else {
                placeholderImage
            }
        }
    }
    
    private var placeholderImage: some View {
        ZStack {
            mutedTeal.opacity(0.15)
            Image(systemName: "fork.knife")
                .font(.system(size: 30))
                .foregroundColor(mutedTeal.opacity(0.5))
        }
    }
}

#Preview {
    FeedCardView(recipe: Recipe(userId: "1", title: "Test Recipe", description: "", ingredients: [], steps: [], category: "Dessert", recipeImage: ""), cardHeight: 250)
        .environmentObject(RecipeViewModel())
}

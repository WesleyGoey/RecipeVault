//
//  RecipeDetailView 2.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 28/05/26.
//

import SwiftUI

struct RecipeDetailView: View {
    // Uses ObservedObject because the ViewModel is passed in from the previous screen
    @ObservedObject var viewModel: RecipeDetailViewModel
    
    // Theme Colors
    let bgYellow = Color(hex: "f8fae5")
    let burntOrange = Color(hex: "cd4b12")
    let mutedTeal = Color(hex: "43766c")
    let darkText = Color.primary
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                // 1. Hero Image (Now downloads from internet!)
                heroImageSection
                
                // 2. Author Attribution
                attributionSection
                
                VStack(alignment: .leading, spacing: 20) {
                    // 3. Title, Plus Button & Favorite Button
                    titleSection
                    
                    // 4. Meta Info (Time & Servings)
                    metaSection
                    
                    // 5. Tags (Now uses real data)
                    tagsSection
                    
                    // 6. Custom Segmented Control
                    customPicker
                    
                    // 7. Dynamic List (Ingredients or Steps)
                    if viewModel.currentTab == .ingredients {
                        ingredientsList
                    } else {
                        stepsList
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(bgYellow.ignoresSafeArea())
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        // This attaches the Collection Bottom Sheet to the View
        .sheet(isPresented: $viewModel.showCollectionSheet) {
            // Temporary Text until we build the actual Bottom Sheet UI
            VStack {
                Text("Save to Collection")
                    .font(.headline)
                    .padding()
                Text("You have \(viewModel.userCollections.count) collections.")
            }
            .presentationDetents([.medium]) // Makes it a half-screen sheet!
        }
    }
}

// MARK: - Subviews
extension RecipeDetailView {
    
    private var heroImageSection: some View {
        ZStack(alignment: .topLeading) {
            // 🚀 AsyncImage to load TheMealDB URLs
            AsyncImage(url: URL(string: viewModel.recipe.recipeImage)) { phase in
                switch phase {
                case .empty:
                    Rectangle().fill(Color.gray.opacity(0.3))
                        .overlay(ProgressView()) // Loading spinner
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Rectangle().fill(Color.gray.opacity(0.3))
                        .overlay(Image(systemName: "photo").foregroundColor(.gray))
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 300)
            .clipped()
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.6)]),
                    startPoint: .center,
                    endPoint: .bottom
                )
            )
            
            // Custom Back Button
            Button(action: {
                // TODO: Add Navigation pop action
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Circle())
            }
            .padding(.top, 50)
            .padding(.leading, 20)
        }
    }
    
    private var attributionSection: some View {
        HStack {
            Circle()
                .fill(mutedTeal)
                .frame(width: 40, height: 40)
                .overlay(Text("TM").foregroundColor(.white).font(.caption.bold()))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("TheMealDB")
                    .font(.custom("Merriweather-Bold", size: 16, relativeTo: .headline))
                Text("@themealdb")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(20)
        .background(bgYellow)
    }
    
    private var titleSection: some View {
        HStack(alignment: .top) {
            Text(viewModel.recipe.title)
                .font(.custom("Merriweather-Bold", size: 32, relativeTo: .largeTitle))
                .foregroundColor(darkText)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            HStack(spacing: 12) {
                // The PLUS Button (Opens Collection Sheet)
                Button(action: {
                    Task { await viewModel.openCollectionSheet() }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(burntOrange)
                        .padding(12)
                        .background(burntOrange.opacity(0.15))
                        .clipShape(Circle())
                }
                
                // The HEART Button (Favorites)
                Button(action: {
                    Task { await viewModel.toggleFavorite() }
                }) {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .padding(14)
                        .background(burntOrange)
                        .clipShape(Circle())
                        .shadow(color: burntOrange.opacity(0.4), radius: 8, x: 0, y: 4)
                }
            }
            .padding(.top, 4)
        }
    }
    
    private var metaSection: some View {
        HStack(spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "clock")
                Text("35 min") // We can make this dynamic later if needed
            }
            Text("·")
                .fontWeight(.bold)
            Text("4 servings") // We can make this dynamic later if needed
        }
        .font(.subheadline)
        .foregroundColor(.gray)
    }
    
    private var tagsSection: some View {
        HStack(spacing: 10) {
            // 🚀 Now uses the actual category from your Database/MealDB!
            let tags = [viewModel.recipe.category]
            
            ForEach(tags.filter { !$0.isEmpty }, id: \.self) { tag in
                Text(tag)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(burntOrange)
                    .clipShape(Capsule())
            }
        }
    }
    
    private var customPicker: some View {
        HStack(spacing: 0) {
            PickerTab(title: "Ingredients", isSelected: viewModel.currentTab == .ingredients) {
                withAnimation(.easeInOut(duration: 0.2)) { viewModel.currentTab = .ingredients }
            }
            PickerTab(title: "Steps", isSelected: viewModel.currentTab == .steps) {
                withAnimation(.easeInOut(duration: 0.2)) { viewModel.currentTab = .steps }
            }
        }
        .padding(6)
        .background(mutedTeal.opacity(0.15))
        .clipShape(Capsule())
        .padding(.vertical, 10)
    }
    
    private var ingredientsList: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.recipe.ingredients, id: \.self) { ingredient in
                HStack(spacing: 16) {
                    Circle()
                        .fill(mutedTeal.opacity(0.7))
                        .frame(width: 10, height: 10)
                        .padding(6)
                        .background(mutedTeal.opacity(0.15))
                        .clipShape(Circle())
                    
                    Text(ingredient)
                        .font(.custom("Merriweather-Regular", size: 18, relativeTo: .body))
                        .foregroundColor(darkText)
                    
                    Spacer()
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.02), radius: 5, x: 0, y: 2)
            }
        }
    }
    
    private var stepsList: some View {
        VStack(spacing: 12) {
            ForEach(Array(viewModel.recipe.steps.enumerated()), id: \.element) { index, step in
                HStack(alignment: .top, spacing: 16) {
                    Text("\(index + 1)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(mutedTeal)
                        .clipShape(Circle())
                    
                    Text(step)
                        .font(.custom("Merriweather-Regular", size: 18, relativeTo: .body))
                        .foregroundColor(darkText)
                        .lineSpacing(4)
                        .padding(.top, 4)
                    
                    Spacer()
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.02), radius: 5, x: 0, y: 2)
            }
        }
    }
}

// MARK: - Helper Components
struct PickerTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Merriweather-Bold", size: 16, relativeTo: .headline))
                .foregroundColor(isSelected ? .black : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? Color.white : Color.clear)
                .clipShape(Capsule())
                .shadow(color: isSelected ? .black.opacity(0.05) : .clear, radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Preview with LIVE TheMealDB Data
#Preview {
    PreviewLiveWrapper()
}

struct PreviewLiveWrapper: View {
    @State private var viewModel: RecipeDetailViewModel?
    
    var body: some View {
        Group {
            if let vm = viewModel {
                RecipeDetailView(viewModel: vm)
            } else {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Fetching live data from TheMealDB...")
                        .font(.custom("Merriweather-Regular", size: 16))
                        .foregroundColor(.gray)
                }
                .task {
                    await fetchRealData()
                }
            }
        }
    }
    
    // Makes a real network call just for the Canvas Preview!
    func fetchRealData() async {
        do {
            let url = URL(string: "https://www.themealdb.com/api/json/v1/1/random.php")!
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // Parse the raw JSON manually so we don't interfere with your actual App Models
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let meals = json["meals"] as? [[String: Any]],
               let firstMeal = meals.first {
                
                let title = firstMeal["strMeal"] as? String ?? "Unknown"
                let category = firstMeal["strCategory"] as? String ?? "General"
                let area = firstMeal["strArea"] as? String ?? "Unknown"
                let instructions = firstMeal["strInstructions"] as? String ?? ""
                let image = firstMeal["strMealThumb"] as? String ?? ""
                let mealId = firstMeal["idMeal"] as? String ?? UUID().uuidString
                
                // Break the giant paragraph into clean steps
                let parsedSteps = instructions
                    .components(separatedBy: .newlines)
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                
                var realRecipe = Recipe(
                    userId: "themealdb",
                    title: title,
                    description: "A traditional \(area) dish.",
                    ingredients: ["(Ingredient parsing coming soon)"],
                    steps: parsedSteps,
                    category: category,
                    recipeImage: image
                )
                
                realRecipe.id = mealId
                realRecipe.createdAt = Date()
                
                // Update the state to swap out the loading spinner for the actual UI
                self.viewModel = RecipeDetailViewModel(recipe: realRecipe)
            }
        } catch {
            print("Preview fetch failed: \(error.localizedDescription)")
        }
    }
}

// MARK: - Local Color Extension
// Bypasses the Target Membership bug AND prevents "Invalid redeclaration" errors!
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

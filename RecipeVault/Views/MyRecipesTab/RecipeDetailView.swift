//
//  RecipeDetailView.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 28/05/26.
//

// MARK: - RecipeDetailView
import SwiftUI

struct RecipeDetailView: View {
    // 🚀 Menerima data resep dari layar sebelumnya (Card yang diklik)
    let recipe: Recipe
    
    // 🚀 Menggunakan RecipeViewModel global
    @ObservedObject var viewModel: RecipeViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    // Theme Colors
    let bgYellow = Color(hex: "f8fae5")
    let burntOrange = Color(hex: "cd4b12")
    let mutedTeal = Color(hex: "43766c")
    let darkText = Color.primary
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                heroImageSection
                attributionSection
                
                VStack(alignment: .leading, spacing: 20) {
                    titleSection
                    tagsSection
                    customPicker
                    
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
        .onAppear {
            Task { await viewModel.checkIfFavorite(recipe: recipe) }
        }
        
        // MARK: - Modals & Sheets
        .sheet(isPresented: $viewModel.showCollectionSheet) {
            VStack {
                Text("Save to Collection")
                    .font(.headline)
                    .padding()
                Text("You have \(viewModel.userCollections.count) collections.")
                
                // Panggil save menggunakan resep aktif
                Button("Save") {
                    Task { await viewModel.saveToSelectedCollections(recipe: recipe) }
                }
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showingEditSheet) {
            // 🚀 Buka Edit View sesungguhnya
            RecipeEditView(recipe: recipe)
        }
        .alert("Delete Recipe", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteRecipe(recipe: recipe)
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to delete this recipe? This action cannot be undone.")
        }
    }
}

// MARK: - Subviews
extension RecipeDetailView {
    
    private var heroImageSection: some View {
        ZStack(alignment: .top) {
            AsyncImage(url: URL(string: recipe.recipeImage)) { phase in
                switch phase {
                case .empty:
                    Rectangle().fill(Color.gray.opacity(0.3)).overlay(ProgressView())
                case .success(let image):
                    // 🚀 FIX: Menggunakan Color.clear sebagai batas keras (hard limit)
                    // Trik ini mencegah ScaledToFill melebarkan ScrollView ke luar layar!
                    Color.clear
                        .overlay(
                            image
                                .resizable()
                                .scaledToFill()
                        )
                        .clipped()
                case .failure:
                    Rectangle().fill(Color.gray.opacity(0.3)).overlay(Image(systemName: "photo").foregroundColor(.gray))
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 300)
            .frame(maxWidth: .infinity)
            .clipped()
            .overlay(
                LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.6)]), startPoint: .center, endPoint: .bottom)
            )
            
            // Top Navigation Bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44) // Menggunakan frame simetris
                        .background(Color.black.opacity(0.4))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                // Tampilkan menu titik tiga HANYA jika User pemilik resep
                if viewModel.isOwner(recipe: recipe) {
                    Menu {
                        Button {
                            showingEditSheet = true
                        } label: {
                            Label("Edit Recipe", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete Recipe", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44) // Menggunakan frame simetris
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.top, 50)
            .padding(.horizontal, 20)
        }
    }
    
    private var attributionSection: some View {
        HStack {
            Circle().fill(mutedTeal).frame(width: 40, height: 40).overlay(Text("TM").foregroundColor(.white).font(.caption.bold()))
            VStack(alignment: .leading, spacing: 2) {
                Text("TheMealDB").font(.custom("Merriweather-Bold", size: 16, relativeTo: .headline))
                Text("@themealdb").font(.subheadline).foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundColor(.gray)
        }
        .padding(20)
        .background(bgYellow)
    }
    
    private var titleSection: some View {
        HStack(alignment: .top) {
            Text(recipe.title)
                .font(.custom("Merriweather-Bold", size: 28, relativeTo: .largeTitle))
                .foregroundColor(darkText)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            HStack(spacing: 12) {
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
                
                Button(action: {
                    Task { await viewModel.toggleFavorite(recipe: recipe) }
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
    
    private var tagsSection: some View {
        HStack(spacing: 10) {
            let tags = [recipe.category]
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
            ForEach(recipe.ingredients, id: \.self) { ingredient in
                HStack(spacing: 16) {
                    Circle().fill(mutedTeal.opacity(0.7)).frame(width: 10, height: 10).padding(6).background(mutedTeal.opacity(0.15)).clipShape(Circle())
                    Text(ingredient).font(.custom("Merriweather-Regular", size: 18, relativeTo: .body)).foregroundColor(darkText)
                    Spacer()
                }
                .padding(16).background(Color.white).cornerRadius(16).shadow(color: .black.opacity(0.02), radius: 5, x: 0, y: 2)
            }
        }
    }
    
    private var stepsList: some View {
        VStack(spacing: 12) {
            ForEach(Array(recipe.steps.enumerated()), id: \.element) { index, step in
                HStack(alignment: .top, spacing: 16) {
                    Text("\(index + 1)").font(.headline).foregroundColor(.white).frame(width: 32, height: 32).background(mutedTeal).clipShape(Circle())
                    Text(step).font(.custom("Merriweather-Regular", size: 18, relativeTo: .body)).foregroundColor(darkText).lineSpacing(4).padding(.top, 4)
                    Spacer()
                }
                .padding(16).background(Color.white).cornerRadius(16).shadow(color: .black.opacity(0.02), radius: 5, x: 0, y: 2)
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

// MARK: - Preview dengan LIVE TheMealDB Data
#Preview {
    PreviewLiveWrapper()
}

struct PreviewLiveWrapper: View {
    @State private var fetchedRecipe: Recipe?
    @StateObject private var sharedViewModel = RecipeViewModel()
    
    var body: some View {
        Group {
            if let recipe = fetchedRecipe {
                RecipeDetailView(recipe: recipe, viewModel: sharedViewModel)
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
    
    func fetchRealData() async {
        do {
            let url = URL(string: "https://www.themealdb.com/api/json/v1/1/random.php")!
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let meals = json["meals"] as? [[String: Any]],
               let firstMeal = meals.first {
                
                let title = firstMeal["strMeal"] as? String ?? "Unknown"
                let category = firstMeal["strCategory"] as? String ?? "General"
                let area = firstMeal["strArea"] as? String ?? "Unknown"
                let instructions = firstMeal["strInstructions"] as? String ?? ""
                let image = firstMeal["strMealThumb"] as? String ?? ""
                let mealId = firstMeal["idMeal"] as? String ?? UUID().uuidString
                
                var parsedIngredients: [String] = []
                for i in 1...20 {
                    if let ingredient = firstMeal["strIngredient\(i)"] as? String,
                       !ingredient.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        let measure = (firstMeal["strMeasure\(i)"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                        let combined = measure.isEmpty ? ingredient : "\(measure) \(ingredient)"
                        parsedIngredients.append(combined)
                    }
                }
                
                let parsedSteps = instructions
                    .components(separatedBy: .newlines)
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                
                var realRecipe = Recipe(
                    userId: "themealdb",
                    title: title,
                    description: "A traditional \(area) dish.",
                    ingredients: parsedIngredients,
                    steps: parsedSteps,
                    category: category,
                    recipeImage: image
                )
                
                realRecipe.id = mealId
                realRecipe.createdAt = Date()
                
                self.fetchedRecipe = realRecipe
            }
        } catch {
            print("Preview fetch failed: \(error.localizedDescription)")
        }
    }
}

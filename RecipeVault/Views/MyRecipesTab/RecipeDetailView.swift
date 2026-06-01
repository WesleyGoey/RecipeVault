//
//  RecipeDetailView.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 28/05/26.
//

import SwiftUI
import FirebaseFirestore

struct RecipeDetailView: View {
    @State private var recipe: Recipe
    @ObservedObject var viewModel: RecipeViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var isLoadingDetails = false
    
    // 🚀 State untuk menampung nama & foto pembuat resep
    @State private var creatorName: String = "Loading..."
    @State private var creatorProfilePic: String = ""
    
    let bgYellow = Color(hex: "f8fae5")
    let burntOrange = Color(hex: "cd4b12")
    let mutedTeal = Color(hex: "43766c")
    let darkText = Color.primary
    
    init(recipe: Recipe, viewModel: RecipeViewModel) {
        self._recipe = State(initialValue: recipe)
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroImageSection
                
                authorSection
                
                VStack(alignment: .leading, spacing: 20) {
                    titleSection
                    tagsSection
                    customPicker
                    
                    if isLoadingDetails {
                        ProgressView().scaleEffect(1.5).frame(maxWidth: .infinity).padding(.top, 40)
                    } else {
                        if viewModel.currentTab == .ingredients {
                            ingredientsList
                        } else {
                            stepsList
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(bgYellow.ignoresSafeArea())
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .onChange(of: viewModel.myRecipes) { updatedRecipes in
            if let latestRecipeData = updatedRecipes.first(where: { $0.id == recipe.id }) {
                withAnimation {
                    self.recipe = latestRecipeData
                }
            }
        }
        .task {
            // Ambil detail bahan jika kosong (dari TheMealDB)
            if recipe.ingredients.isEmpty, let mealId = recipe.id {
                await fetchFullDetails(id: mealId)
            }
            
            // 🚀 FETCH USER PROFILE NAME & PICTURE
            if recipe.userId == "themealdb" {
                creatorName = "TheMealDB"
            } else {
                do {
                    let db = Firestore.firestore()
                    let doc = try await db.collection("users").document(recipe.userId).getDocument()
                    if let data = doc.data() {
                        creatorName = data["name"] as? String ?? "Unknown Chef"
                        creatorProfilePic = data["profilePicture"] as? String ?? ""
                        // Timpa "You" jika itu kita sendiri, tapi tetap ambil fotonya
                        if viewModel.isOwner(recipe: recipe) {
                            creatorName = "You"
                        }
                    } else {
                        creatorName = "Unknown Chef"
                    }
                } catch {
                    creatorName = "Unknown Chef"
                }
            }
        }
        
        // BOTTOM SHEET KOLEKSI
        .sheet(isPresented: $viewModel.showCollectionSheet) {
            CollectionSelectionSheet(viewModel: viewModel)
        }
        
        .sheet(isPresented: $showingEditSheet) {
            RecipeEditView(recipeToEdit: recipe, viewModel: viewModel)
        }
        
        // REVISI FITUR DELETE
        .alert("Delete Recipe", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                dismiss()
                Task {
                    try? await Task.sleep(nanoseconds: 250_000_000)
                    await viewModel.deleteRecipe(recipe: recipe)
                }
            }
        } message: {
            Text("Are you sure you want to delete this recipe? This action cannot be undone.")
        }
    }
    
    private func fetchFullDetails(id: String) async {
        isLoadingDetails = true
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(id)") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let meals = json["meals"] as? [[String: Any]],
               let fullMeal = meals.first {
                
                var parsedIngredients: [String] = []
                for i in 1...20 {
                    if let ingredient = fullMeal["strIngredient\(i)"] as? String,
                       !ingredient.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        let measure = (fullMeal["strMeasure\(i)"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                        let combined = measure.isEmpty ? ingredient : "\(measure) \(ingredient)"
                        parsedIngredients.append(combined)
                    }
                }
                
                let instructions = fullMeal["strInstructions"] as? String ?? ""
                let parsedSteps = instructions.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
                
                withAnimation {
                    recipe.ingredients = parsedIngredients
                    recipe.steps = parsedSteps
                }
            }
        } catch {
            print("Failed to fetch full recipe details: \(error.localizedDescription)")
        }
        isLoadingDetails = false
    }
}

extension RecipeDetailView {
    
    // MARK: - Hero Image Section
    private var heroImageSection: some View {
        ZStack(alignment: .top) {
            if recipe.recipeImage.isEmpty {
                ZStack {
                    mutedTeal.opacity(0.15)
                    Image(systemName: "fork.knife")
                        .font(.system(size: 60))
                        .foregroundColor(mutedTeal.opacity(0.5))
                }
                .frame(height: 300).frame(maxWidth: .infinity).clipped()
            }
            // RENDER GAMBAR DARI THEMEALDB URL
            else if recipe.recipeImage.starts(with: "http") {
                AsyncImage(url: URL(string: recipe.recipeImage.trimmingCharacters(in: .whitespacesAndNewlines))) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else if phase.error != nil {
                        ZStack {
                            mutedTeal.opacity(0.15)
                            Image(systemName: "fork.knife").font(.system(size: 60)).foregroundColor(mutedTeal.opacity(0.5))
                        }
                    } else {
                        ZStack {
                            mutedTeal.opacity(0.15)
                            ProgressView()
                        }
                    }
                }
                .frame(height: 300).frame(maxWidth: .infinity).clipped()
            }
            // RENDER GAMBAR DARI TEXT BASE64
            else if let imageData = Data(base64Encoded: recipe.recipeImage),
                    let uiImage = UIImage(data: imageData) {
                
                Color.clear.overlay(
                    Image(uiImage: uiImage).resizable().scaledToFill()
                ).clipped()
                .frame(height: 300).frame(maxWidth: .infinity).clipped()
                
            } else {
                ZStack {
                    mutedTeal.opacity(0.15)
                    Image(systemName: "fork.knife")
                        .font(.system(size: 60))
                        .foregroundColor(mutedTeal.opacity(0.5))
                }
                .frame(height: 300).frame(maxWidth: .infinity).clipped()
            }
            
            // Overlay Gradient agar tombol back terlihat jelas
            LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.6)]), startPoint: .center, endPoint: .bottom)
                .frame(height: 300)
            
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left").font(.system(size: 16, weight: .bold)).foregroundColor(.white).frame(width: 44, height: 44).background(Color.black.opacity(0.4)).clipShape(Circle())
                }
                Spacer()
                if viewModel.isOwner(recipe: recipe) {
                    Menu {
                        Button { showingEditSheet = true } label: { Label("Edit Recipe", systemImage: "pencil") }
                        Button(role: .destructive) { showingDeleteAlert = true } label: { Label("Delete Recipe", systemImage: "trash") }
                    } label: {
                        Image(systemName: "ellipsis").font(.system(size: 18, weight: .bold)).foregroundColor(.white).frame(width: 44, height: 44).background(Color.black.opacity(0.4)).clipShape(Circle())
                    }
                }
            }
            .padding(.top, 50).padding(.horizontal, 20)
        }
    }
    
    private var titleSection: some View {
        HStack(alignment: .top) {
            Text(recipe.title)
                .font(.merriweather(28, weight: .bold))
                .foregroundColor(darkText)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            
            HStack(spacing: 12) {
                
                // TOMBOL ADD TO COLLECTION
                Button(action: { Task { await viewModel.openCollectionSheet(for: recipe) } }) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(burntOrange)
                        .padding(12)
                        .background(burntOrange.opacity(0.15))
                        .clipShape(Circle())
                }
                
                // TOMBOL FAVORITE
                let isFav = viewModel.isFavorite(recipe: recipe)
                Button(action: { Task { await viewModel.toggleFavorite(recipe: recipe) } }) {
                    Image(systemName: isFav ? "heart.fill" : "heart")
                        .font(.system(size: 20))
                        .foregroundColor(isFav ? .white : burntOrange)
                        .padding(14)
                        .background(isFav ? burntOrange : burntOrange.opacity(0.15))
                        .clipShape(Circle())
                        .shadow(color: isFav ? burntOrange.opacity(0.4) : .clear, radius: 8, x: 0, y: 4)
                }
            }
            .padding(.top, 4)
        }
    }
    
    // 🚀 BISA DI-KLIK & MENAMPILKAN FOTO PROFIL AUTHOR
    private var authorSection: some View {
        Group {
            // JIKA DARI API THEMEALDB
            if recipe.userId == "themealdb" {
                HStack {
                    Circle().fill(mutedTeal).frame(width: 46, height: 46).overlay(Text("TM").foregroundColor(.white).font(.system(size: 14, weight: .bold)))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("TheMealDB").font(.merriweather(16, weight: .bold)).foregroundColor(darkText)
                        Text("@themealdb").font(.merriweather(14, weight: .regular)).foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(20).background(bgYellow)
            }
            // JIKA DARI USER SUNGGUHAN
            else {
                NavigationLink(destination: OtherProfileView(creatorId: recipe.userId)) {
                    HStack(spacing: 12) {
                        
                        // 🚀 LOGIKA FOTO PROFIL AUTHOR
                        ZStack {
                            Circle().fill(mutedTeal).frame(width: 46, height: 46)
                            if !creatorProfilePic.isEmpty {
                                if creatorProfilePic.hasPrefix("http") {
                                    AsyncImage(url: URL(string: creatorProfilePic)) { phase in
                                        if let image = phase.image {
                                            image.resizable().scaledToFill()
                                        } else {
                                            Text(String(creatorName.prefix(2)).uppercased())
                                                .font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                                        }
                                    }
                                    .frame(width: 46, height: 46).clipShape(Circle())
                                } else if let data = Data(base64Encoded: creatorProfilePic), let uiImg = UIImage(data: data) {
                                    Image(uiImage: uiImg).resizable().scaledToFill().frame(width: 46, height: 46).clipShape(Circle())
                                } else {
                                    Text(String(creatorName.prefix(2)).uppercased())
                                        .font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                                }
                            } else {
                                Text(String(creatorName.prefix(2)).uppercased())
                                    .font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                            }
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(creatorName).font(.merriweather(16, weight: .bold)).foregroundColor(darkText)
                            Text(viewModel.isOwner(recipe: recipe) ? "Your Recipe" : "Public Creator")
                                .font(.merriweather(14, weight: .regular)).foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").foregroundColor(.gray)
                    }
                    .padding(20).background(bgYellow)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var tagsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                let tags = recipe.category.components(separatedBy: ",")
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
                
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.merriweather(12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(burntOrange)
                        .clipShape(Capsule())
                }
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
        .padding(6).background(mutedTeal.opacity(0.15)).clipShape(Capsule()).padding(.vertical, 10)
    }
    
    private var ingredientsList: some View {
        VStack(spacing: 12) {
            ForEach(recipe.ingredients, id: \.self) { ingredient in
                HStack(spacing: 16) {
                    Circle().fill(mutedTeal.opacity(0.7)).frame(width: 10, height: 10).padding(6).background(mutedTeal.opacity(0.15)).clipShape(Circle())
                    Text(ingredient).font(.merriweather(16, weight: .regular)).foregroundColor(darkText)
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
                    Text("\(index + 1)").font(.merriweather(14, weight: .bold)).foregroundColor(.white).frame(width: 32, height: 32).background(mutedTeal).clipShape(Circle())
                    Text(step).font(.merriweather(16, weight: .regular)).foregroundColor(darkText).lineSpacing(4).padding(.top, 4)
                    Spacer()
                }
                .padding(16).background(Color.white).cornerRadius(16).shadow(color: .black.opacity(0.02), radius: 5, x: 0, y: 2)
            }
        }
    }
}

struct PickerTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title).font(.merriweather(16, weight: .bold)).foregroundColor(isSelected ? .black : .gray).frame(maxWidth: .infinity).padding(.vertical, 12).background(isSelected ? Color.white : Color.clear).clipShape(Capsule()).shadow(color: isSelected ? .black.opacity(0.05) : .clear, radius: 4, x: 0, y: 2)
        }
    }
}

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
                        .font(.merriweather(16, weight: .regular))
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

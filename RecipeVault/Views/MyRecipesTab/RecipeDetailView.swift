//
//  RecipeDetailView.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 28/05/26.
//

import FirebaseFirestore
import SwiftUI

struct RecipeDetailView: View {
    @State private var recipe: Recipe
    @ObservedObject var viewModel: RecipeViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var isLoadingDetails = false

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
                        ProgressView().scaleEffect(1.5).frame(
                            maxWidth: .infinity
                        ).padding(.top, 40)
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
            if let latestRecipeData = updatedRecipes.first(where: {
                $0.id == recipe.id
            }) {
                withAnimation {
                    self.recipe = latestRecipeData
                }
            }
        }
        .task {
            let isImageEmpty = recipe.recipeImage.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty
            if recipe.ingredients.isEmpty || isImageEmpty,
                let mealId = recipe.id
            {
                await fetchFullDetails(id: mealId)
            }

            if recipe.userId == "themealdb" {
                creatorName = "TheMealDB"
            } else {
                do {
                    let db = Firestore.firestore()
                    let doc = try await db.collection("users").document(
                        recipe.userId
                    ).getDocument()
                    if let data = doc.data() {
                        creatorName = data["name"] as? String ?? "Unknown Chef"
                        creatorProfilePic =
                            data["profilePicture"] as? String ?? ""
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
        .sheet(isPresented: $viewModel.showCollectionSheet) {
            CollectionSelectionSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showingEditSheet) {
            RecipeEditView(recipeToEdit: recipe, viewModel: viewModel)
        }
        .alert("Delete Recipe", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                dismiss()
                Task {
                    try? await Task.sleep(nanoseconds: 250_000_000)
                    await viewModel.deleteRecipe(recipe: recipe)
                }
            }
        } message: {
            Text(
                "Are you sure you want to delete this recipe? This action cannot be undone."
            )
        }
    }

    private func fetchFullDetails(id: String) async {
        isLoadingDetails = true
        guard
            let url = URL(
                string:
                    "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(id)"
            )
        else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try JSONSerialization.jsonObject(with: data)
                as? [String: Any],
                let meals = json["meals"] as? [[String: Any]],
                let fullMeal = meals.first
            {

                let mealThumb = fullMeal["strMealThumb"] as? String ?? ""

                var parsedIngredients: [String] = []
                for i in 1...20 {
                    if let ingredient = fullMeal["strIngredient\(i)"]
                        as? String,
                        !ingredient.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty
                    {
                        let measure =
                            (fullMeal["strMeasure\(i)"] as? String)?
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            ?? ""
                        let combined =
                            measure.isEmpty
                            ? ingredient : "\(measure) \(ingredient)"
                        parsedIngredients.append(combined)
                    }
                }

                let instructions = fullMeal["strInstructions"] as? String ?? ""
                let parsedSteps = instructions.components(
                    separatedBy: .newlines
                ).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }

                withAnimation {
                    // Update bahan & langkah hanya jika sebelumnya kosong
                    if recipe.ingredients.isEmpty {
                        recipe.ingredients = parsedIngredients
                    }
                    if recipe.steps.isEmpty {
                        recipe.steps = parsedSteps
                    }

                    // Update gambar jika sebelumnya kosong
                    if recipe.recipeImage.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ).isEmpty && !mealThumb.isEmpty {
                        recipe.recipeImage = mealThumb
                    }
                }
            }
        } catch {
            print(
                "Failed to fetch full recipe details: \(error.localizedDescription)"
            )
        }
        isLoadingDetails = false
    }
}

extension RecipeDetailView {
    // MARK: - Hero Image Section
    private var heroImageSection: some View {
        ZStack(alignment: .top) {
            let cleanImg = recipe.recipeImage.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

            if cleanImg.isEmpty {
                defaultPlaceholder
            }
            // RENDER GAMBAR URL
            else if cleanImg.hasPrefix("http") {
                AsyncImage(url: URL(string: cleanImg)) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else if phase.error != nil {
                        defaultPlaceholder
                    } else {
                        ZStack {
                            mutedTeal.opacity(0.15)
                            ProgressView()
                        }
                    }
                }
                .frame(height: 300).frame(maxWidth: .infinity).clipped()
            }
            // RENDER GAMBAR BASE64
            else if let imageData = Data(base64Encoded: cleanImg),
                let uiImage = UIImage(data: imageData)
            {
                Color.clear.overlay(
                    Image(uiImage: uiImage).resizable().scaledToFill()
                ).clipped()
                    .frame(height: 300).frame(maxWidth: .infinity).clipped()
            } else {
                defaultPlaceholder
            }

            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.6)]),
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(height: 300)

            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left").font(
                        .system(size: 16, weight: .bold)
                    ).foregroundColor(.white).frame(width: 44, height: 44)
                        .background(Color.black.opacity(0.4)).clipShape(
                            Circle()
                        )
                }
                Spacer()
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
                        Image(systemName: "ellipsis").font(
                            .system(size: 18, weight: .bold)
                        ).foregroundColor(.white).frame(width: 44, height: 44)
                            .background(Color.black.opacity(0.4)).clipShape(
                                Circle()
                            )
                    }
                }
            }
            .padding(.top, 50).padding(.horizontal, 20)
        }
    }

    private var defaultPlaceholder: some View {
        ZStack {
            mutedTeal.opacity(0.15)
            Image(systemName: "fork.knife")
                .font(.system(size: 60))
                .foregroundColor(mutedTeal.opacity(0.5))
        }
        .frame(height: 300).frame(maxWidth: .infinity).clipped()
    }

    private var titleSection: some View {
        HStack(alignment: .top) {
            Text(recipe.title)
                .font(.merriweather(28, weight: .bold))
                .foregroundColor(darkText)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()

            HStack(spacing: 12) {
                Button(action: {
                    Task { await viewModel.openCollectionSheet(for: recipe) }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(burntOrange)
                        .padding(12)
                        .background(burntOrange.opacity(0.15))
                        .clipShape(Circle())
                }

                let isFav = viewModel.isFavorite(recipe: recipe)
                Button(action: {
                    Task { await viewModel.toggleFavorite(recipe: recipe) }
                }) {
                    Image(systemName: isFav ? "heart.fill" : "heart")
                        .font(.system(size: 20))
                        .foregroundColor(isFav ? .white : burntOrange)
                        .padding(14)
                        .background(
                            isFav ? burntOrange : burntOrange.opacity(0.15)
                        )
                        .clipShape(Circle())
                        .shadow(
                            color: isFav ? burntOrange.opacity(0.4) : .clear,
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                }
            }
            .padding(.top, 4)
        }
    }

    private var authorSection: some View {
        Group {
            if recipe.userId == "themealdb" {
                HStack {
                    Circle().fill(mutedTeal).frame(width: 46, height: 46)
                        .overlay(
                            Text("TM").foregroundColor(.white).font(
                                .system(size: 14, weight: .bold)
                            )
                        )
                    VStack(alignment: .leading, spacing: 2) {
                        Text("TheMealDB").font(.merriweather(16, weight: .bold))
                            .foregroundColor(darkText)
                        Text("@themealdb").font(
                            .merriweather(14, weight: .regular)
                        ).foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(20).background(bgYellow)
            } else {
                NavigationLink(
                    destination: OtherProfileView(creatorId: recipe.userId)
                ) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle().fill(mutedTeal).frame(
                                width: 46,
                                height: 46
                            )
                            if !creatorProfilePic.isEmpty {
                                let cleanProfile =
                                    creatorProfilePic.trimmingCharacters(
                                        in: .whitespacesAndNewlines
                                    )
                                if cleanProfile.hasPrefix("http") {
                                    AsyncImage(url: URL(string: cleanProfile)) {
                                        phase in
                                        if let image = phase.image {
                                            image.resizable().scaledToFill()
                                        } else {
                                            Text(
                                                String(creatorName.prefix(2))
                                                    .uppercased()
                                            )
                                            .font(
                                                .system(size: 14, weight: .bold)
                                            ).foregroundColor(.white)
                                        }
                                    }
                                    .frame(width: 46, height: 46).clipShape(
                                        Circle()
                                    )
                                } else if let data = Data(
                                    base64Encoded: cleanProfile
                                ), let uiImg = UIImage(data: data) {
                                    Image(uiImage: uiImg).resizable()
                                        .scaledToFill().frame(
                                            width: 46,
                                            height: 46
                                        ).clipShape(Circle())
                                } else {
                                    Text(
                                        String(creatorName.prefix(2))
                                            .uppercased()
                                    )
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                }
                            } else {
                                Text(String(creatorName.prefix(2)).uppercased())
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(creatorName).font(
                                .merriweather(16, weight: .bold)
                            ).foregroundColor(darkText)
                            Text(
                                viewModel.isOwner(recipe: recipe)
                                    ? "Your Recipe" : "Public Creator"
                            )
                            .font(.merriweather(14, weight: .regular))
                            .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").foregroundColor(
                            .gray
                        )
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
            PickerTab(
                title: "Ingredients",
                isSelected: viewModel.currentTab == .ingredients
            ) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.currentTab = .ingredients
                }
            }
            PickerTab(
                title: "Steps",
                isSelected: viewModel.currentTab == .steps
            ) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.currentTab = .steps
                }
            }
        }
        .padding(6).background(mutedTeal.opacity(0.15)).clipShape(Capsule())
        .padding(.vertical, 10)
    }

    private var ingredientsList: some View {
        VStack(spacing: 12) {
            ForEach(recipe.ingredients, id: \.self) { ingredient in
                HStack(spacing: 16) {
                    Circle().fill(mutedTeal.opacity(0.7)).frame(
                        width: 10,
                        height: 10
                    ).padding(6).background(mutedTeal.opacity(0.15)).clipShape(
                        Circle()
                    )
                    Text(ingredient).font(.merriweather(16, weight: .regular))
                        .foregroundColor(darkText)
                    Spacer()
                }
                .padding(16).background(Color.white).cornerRadius(16).shadow(
                    color: .black.opacity(0.02),
                    radius: 5,
                    x: 0,
                    y: 2
                )
            }
        }
    }

    private var stepsList: some View {
        VStack(spacing: 12) {
            ForEach(Array(recipe.steps.enumerated()), id: \.element) {
                index,
                step in
                HStack(alignment: .top, spacing: 16) {
                    Text("\(index + 1)").font(.merriweather(14, weight: .bold))
                        .foregroundColor(.white).frame(width: 32, height: 32)
                        .background(mutedTeal).clipShape(Circle())
                    Text(step).font(.merriweather(16, weight: .regular))
                        .foregroundColor(darkText).lineSpacing(4).padding(
                            .top,
                            4
                        )
                    Spacer()
                }
                .padding(16).background(Color.white).cornerRadius(16).shadow(
                    color: .black.opacity(0.02),
                    radius: 5,
                    x: 0,
                    y: 2
                )
            }
        }
    }
}

// MARK: - PickerTab Component Component
struct PickerTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    let burntOrange = Color(hex: "cd4b12")
    let mutedTeal = Color(hex: "43766c")

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.merriweather(16, weight: .bold))
                .foregroundColor(isSelected ? .white : mutedTeal)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? burntOrange : Color.clear)
                .clipShape(Capsule())
        }
    }
}

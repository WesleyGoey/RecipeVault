//
//  RecipeEditView.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//

import SwiftUI
import PhotosUI

struct RecipeEditView: View {
    @Environment(\.dismiss) var dismiss
    let recipeToEdit: Recipe
    
    @ObservedObject var viewModel: RecipeViewModel
    
    @State private var title: String
    @State private var description: String
    @State private var selectedCategories: Set<String>
    @State private var ingredients: [String]
    @State private var steps: [String]
    
    @State private var photoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    // 🚀 STATE BARU
    @State private var rawImageData: Data?
    
    @State private var isImageDeleted: Bool = false
    
    let categories = ["Beef", "Chicken", "Lamb", "Seafood", "Pasta", "Vegetarian", "Dessert", "Vegan", "Pork", "Side", "Starter", "Breakfast", "Soup", "Spicy", "Gluten-Free", "Dairy-Free", "Miscellaneous"]
    
    let bgYellow = Color(hex: "f8fae5")
    let burntOrange = Color(hex: "cd4b12")
    let mutedTeal = Color(hex: "43766c")
    
    init(recipeToEdit: Recipe, viewModel: RecipeViewModel) {
        self.recipeToEdit = recipeToEdit
        self.viewModel = viewModel
        _title = State(initialValue: recipeToEdit.title)
        _description = State(initialValue: recipeToEdit.description)
        let cats = recipeToEdit.category.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        _selectedCategories = State(initialValue: Set(cats))
        _ingredients = State(initialValue: recipeToEdit.ingredients.isEmpty ? [""] : recipeToEdit.ingredients)
        _steps = State(initialValue: recipeToEdit.steps.isEmpty ? [""] : recipeToEdit.steps)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    photoUploadSection
                    inputSection(title: "RECIPE TITLE", placeholder: "e.g. Grandma's Lasagna", text: $title)
                    descriptionSection
                    categorySection
                    dynamicListSection(title: "INGREDIENTS", items: $ingredients, addPlaceholder: "Add Ingredient", isNumbered: false)
                    dynamicListSection(title: "STEPS", items: $steps, addPlaceholder: "Add Step", isNumbered: true)
                    Spacer().frame(height: 100)
                }
                .padding(20)
            }
            .background(bgYellow.ignoresSafeArea())
            .navigationTitle("Edit Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(burntOrange)
                        .font(.merriweather(16, weight: .bold))
                }
            }
            .overlay(alignment: .bottom) {
                updateButton
            }
            // 🚀 TAMBAHAN: MUNCULKAN ERROR FIREBASE AGAR KAMU TAHU JIKA GAGAL
            .alert("Update Failed", isPresented: Binding(
                get: { !viewModel.operationError.isEmpty },
                set: { if !$0 { viewModel.operationError = "" } }
            )) {
                Button("OK", role: .cancel) { viewModel.operationError = "" }
            } message: {
                Text(viewModel.operationError)
            }
        }
    }
}

extension RecipeEditView {
    
    private var photoUploadSection: some View {
        ZStack(alignment: .topTrailing) {
            
            PhotosPicker(selection: $photoItem, matching: .images, photoLibrary: .shared()) {
                if let selectedImage {
                    Image(uiImage: selectedImage).resizable().scaledToFill().frame(height: 180).frame(maxWidth: .infinity).clipShape(RoundedRectangle(cornerRadius: 16))
                }
                else if !recipeToEdit.recipeImage.isEmpty && !isImageDeleted {
                    // 🚀 DECODE BASE64 LANGSUNG
                    if let imageData = Data(base64Encoded: recipeToEdit.recipeImage),
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 180)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        placeholderView
                    }
                } else {
                    placeholderView
                }
            }
            .onChange(of: photoItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                        self.selectedImage = image
                        self.isImageDeleted = false
                        // Kompres langsung di latar belakang
                        self.rawImageData = image.jpegData(compressionQuality: 0.2)
                    }
                }
            }
            
            if selectedImage != nil || (!recipeToEdit.recipeImage.isEmpty && !isImageDeleted) {
                Button(action: {
                    withAnimation {
                        selectedImage = nil
                        photoItem = nil
                        rawImageData = nil
                        isImageDeleted = true
                    }
                }) {
                    Image(systemName: "trash.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.red)
                        .background(Circle().fill(Color.white))
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .padding(12)
            }
        }
    }
    
    private var placeholderView: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.badge.plus").font(.system(size: 32))
            Text("Add Recipe Photo").font(.merriweather(16, weight: .bold))
            Text("Tap to upload an image").font(.merriweather(12, weight: .regular))
        }
        .foregroundColor(mutedTeal).frame(maxWidth: .infinity).padding(.vertical, 40).background(Color.white).cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(mutedTeal.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [8])))
    }
    
    private func inputSection(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.merriweather(12, weight: .bold)).foregroundColor(.gray)
            TextField(placeholder, text: text).padding(16).background(Color.white).cornerRadius(12).font(.merriweather(14, weight: .regular))
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DESCRIPTION").font(.merriweather(12, weight: .bold)).foregroundColor(.gray)
            ZStack(alignment: .topLeading) {
                if description.isEmpty {
                    Text("e.g. Share the story behind this recipe...")
                        .foregroundColor(Color(UIColor.placeholderText)).font(.merriweather(14, weight: .regular))
                        .padding(.horizontal, 16).padding(.vertical, 16)
                }
                TextEditor(text: $description).font(.merriweather(14, weight: .regular)).padding(8).scrollContentBackground(.hidden)
            }
            .frame(minHeight: 120).background(Color.white).cornerRadius(12)
        }
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("CATEGORY").font(.merriweather(12, weight: .bold)).foregroundColor(.gray)
                Spacer()
                Text("\(selectedCategories.count) selected").font(.merriweather(12, weight: .regular)).foregroundColor(.gray)
            }
            FlowLayout(spacing: 10) {
                ForEach(categories, id: \.self) { category in
                    let isSelected = selectedCategories.contains(category)
                    Button(action: {
                        if isSelected { selectedCategories.remove(category) } else { selectedCategories.insert(category) }
                    }) {
                        Text(category).font(.merriweather(14, weight: .bold)).padding(.horizontal, 16).padding(.vertical, 10)
                            .background(isSelected ? burntOrange : Color.white).foregroundColor(isSelected ? .white : burntOrange).clipShape(Capsule())
                            .overlay(Capsule().stroke(burntOrange.opacity(0.3), lineWidth: 1))
                    }
                }
            }
        }
    }
    
    private func dynamicListSection(title: String, items: Binding<[String]>, addPlaceholder: String, isNumbered: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.merriweather(12, weight: .bold)).foregroundColor(.gray)
            VStack(spacing: 0) {
                ForEach(0..<items.wrappedValue.count, id: \.self) { index in
                    HStack(spacing: 16) {
                        if isNumbered {
                            Circle().fill(mutedTeal).frame(width: 32, height: 32).overlay(Text("\(index + 1)").font(.merriweather(12, weight: .bold)).foregroundColor(.white))
                        } else {
                            Circle().stroke(mutedTeal.opacity(0.5), lineWidth: 2).frame(width: 20, height: 20).overlay(Circle().fill(mutedTeal).frame(width: 8, height: 8))
                        }
                        TextField(isNumbered ? "Describe step \(index + 1)..." : "Ingredient \(index + 1)", text: items[index]).font(.merriweather(14, weight: .regular))
                        Button(action: { items.wrappedValue.remove(at: index) }) {
                            Image(systemName: "trash").foregroundColor(.red.opacity(0.7)).padding(8).background(Color.red.opacity(0.1)).clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 16).padding(.vertical, 12)
                    Divider().padding(.horizontal, 16)
                }
                Button(action: { items.wrappedValue.append("") }) {
                    HStack(spacing: 16) {
                        Circle().fill(mutedTeal.opacity(0.1)).frame(width: 32, height: 32).overlay(Image(systemName: "plus").foregroundColor(mutedTeal))
                        Text(addPlaceholder).font(.merriweather(14, weight: .bold)).foregroundColor(mutedTeal)
                        Spacer()
                    }
                    .padding(.horizontal, 16).padding(.vertical, 12)
                }
            }
            .background(Color.white).cornerRadius(16)
        }
    }
    
    private var updateButton: some View {
        Button(action: {
            Task {
                let catString = selectedCategories.joined(separator: ", ")
                guard let recipeId = recipeToEdit.id else { return }
                
                let success = await viewModel.updateRecipe(
                    recipeId: recipeId,
                    title: title,
                    description: description,
                    category: catString,
                    ingredients: ingredients,
                    steps: steps,
                    oldImageURL: recipeToEdit.recipeImage,
                    newImageData: rawImageData, // 🚀 Tidak macet lagi!
                    isImageDeleted: isImageDeleted
                )
                
                if success { dismiss() }
            }
        }) {
            HStack {
                if viewModel.isLoading { ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)).padding(.trailing, 8) }
                Text(viewModel.isLoading ? "Updating..." : "Update Recipe").font(.merriweather(16, weight: .bold)).foregroundColor(.white)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 16).background(mutedTeal).cornerRadius(16)
        }
        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isLoading)
        .padding(.horizontal, 20).padding(.bottom, 10)
        .background(LinearGradient(gradient: Gradient(colors: [bgYellow.opacity(0), bgYellow]), startPoint: .top, endPoint: .bottom))
    }
}

#Preview {
    RecipeEditView(recipeToEdit: Recipe.mockRecipes[0], viewModel: RecipeViewModel())
}

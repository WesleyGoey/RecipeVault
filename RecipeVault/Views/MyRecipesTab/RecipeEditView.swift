//
//  RecipeEditView.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//

import SwiftUI
import PhotosUI

// MARK: - RecipeEditView
struct RecipeEditView: View {
    
    // MARK: - Properties
    @Environment(\.dismiss) var dismiss
    
    // Parameter resep yang akan diedit
    let recipeToEdit: Recipe
    
    // State UI
    @State private var title: String
    @State private var description: String
    @State private var selectedCategories: Set<String>
    @State private var ingredients: [String]
    @State private var steps: [String]
    
    // State PhotosPicker
    @State private var photoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
    let categories = ["Beef", "Chicken", "Lamb", "Seafood", "Pasta", "Vegetarian", "Dessert", "Vegan", "Pork", "Side", "Starter", "Breakfast", "Soup", "Spicy", "Gluten-Free", "Dairy-Free", "Miscellaneous"]
    
    // Theme Colors
    let bgYellow = Color(hex: "f8fae5")
    let burntOrange = Color(hex: "cd4b12")
    let mutedTeal = Color(hex: "43766c")
    
    // MARK: - Initializer
    init(recipe: Recipe) {
        self.recipeToEdit = recipe
        
        // Mengisi State form dengan data dari resep yang dilempar
        _title = State(initialValue: recipe.title)
        _description = State(initialValue: recipe.description)
        
        // Konversi String kategori menjadi Set untuk multi-select
        let cats = recipe.category.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        _selectedCategories = State(initialValue: Set(cats))
        
        // Mencegah array kosong agar list tidak hilang
        _ingredients = State(initialValue: recipe.ingredients.isEmpty ? [""] : recipe.ingredients)
        _steps = State(initialValue: recipe.steps.isEmpty ? [""] : recipe.steps)
    }
    
    // MARK: - Body
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
                        .fontWeight(.bold)
                }
            }
            .overlay(alignment: .bottom) {
                updateButton
            }
        }
    }
}

// MARK: - Subviews
extension RecipeEditView {
    
    // 🚀 Perbaikan Utama: Logika Gambar Lama vs Gambar Baru
    private var photoUploadSection: some View {
        PhotosPicker(selection: $photoItem, matching: .images, photoLibrary: .shared()) {
            // 1. Jika ada gambar baru yang dipilih dari galeri
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            // 2. Jika belum pilih gambar baru, tapi resep sudah punya gambar dari internet/database
            else if !recipeToEdit.recipeImage.isEmpty {
                AsyncImage(url: URL(string: recipeToEdit.recipeImage)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle().fill(Color.gray.opacity(0.2)).overlay(ProgressView())
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        placeholderView
                    @unknown default:
                        placeholderView
                    }
                }
                .frame(height: 180)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            // 3. Jika resep sama sekali tidak punya gambar
            else {
                placeholderView
            }
        }
        .onChange(of: photoItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                }
            }
        }
    }
    
    private var placeholderView: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 32))
            Text("Change Recipe Photo")
                .font(.custom("Merriweather-Bold", size: 16))
            Text("Tap to upload a new photo")
                .font(.caption)
        }
        .foregroundColor(mutedTeal)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(mutedTeal.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [8]))
        )
    }
    
    private func inputSection(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.gray)
            
            TextField(placeholder, text: text)
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DESCRIPTION")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.gray)
            
            ZStack(alignment: .topLeading) {
                if description.isEmpty {
                    Text("e.g. Share the story behind this recipe...")
                        .foregroundColor(Color(UIColor.placeholderText))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                }
                
                TextEditor(text: $description)
                    .padding(8)
                    .scrollContentBackground(.hidden)
            }
            .frame(minHeight: 120)
            .background(Color.white)
            .cornerRadius(12)
        }
    }
    
    // 🚀 Menggunakan komponen FlowLayout kustom yang sudah kamu definisikan di modulmu
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("CATEGORY")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                Spacer()
                Text("\(selectedCategories.count) selected")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Catatan: Pastikan struct FlowLayout: Layout ada di dalam proyekmu (biasanya sudah ada dari RecipeCreateView)
            FlowLayout(spacing: 10) {
                ForEach(categories, id: \.self) { category in
                    let isSelected = selectedCategories.contains(category)
                    
                    Button(action: {
                        if isSelected {
                            selectedCategories.remove(category)
                        } else {
                            selectedCategories.insert(category)
                        }
                    }) {
                        Text(category)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(isSelected ? burntOrange : Color.white)
                            .foregroundColor(isSelected ? .white : burntOrange)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(burntOrange.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }
        }
    }
    
    private func dynamicListSection(title: String, items: Binding<[String]>, addPlaceholder: String, isNumbered: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.gray)
            
            VStack(spacing: 0) {
                ForEach(0..<items.wrappedValue.count, id: \.self) { index in
                    HStack(spacing: 16) {
                        if isNumbered {
                            Circle()
                                .fill(mutedTeal)
                                .frame(width: 32, height: 32)
                                .overlay(Text("\(index + 1)").font(.caption.bold()).foregroundColor(.white))
                        } else {
                            Circle()
                                .stroke(mutedTeal.opacity(0.5), lineWidth: 2)
                                .frame(width: 20, height: 20)
                                .overlay(Circle().fill(mutedTeal).frame(width: 8, height: 8))
                        }
                        
                        TextField(isNumbered ? "Describe step \(index + 1)..." : "Ingredient \(index + 1)", text: items[index])
                        
                        Button(action: {
                            items.wrappedValue.remove(at: index)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red.opacity(0.7))
                                .padding(8)
                                .background(Color.red.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    
                    Divider().padding(.horizontal, 16)
                }
                
                Button(action: {
                    items.wrappedValue.append("")
                }) {
                    HStack(spacing: 16) {
                        Circle()
                            .fill(mutedTeal.opacity(0.1))
                            .frame(width: 32, height: 32)
                            .overlay(Image(systemName: "plus").foregroundColor(mutedTeal))
                        
                        Text(addPlaceholder)
                            .font(.custom("Merriweather-Bold", size: 14))
                            .foregroundColor(mutedTeal)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .background(Color.white)
            .cornerRadius(16)
        }
    }
    
    private var updateButton: some View {
        Button(action: {
            // TODO: Memanggil fungsi update di RecipeViewModel
            // viewModel.updateRecipe(recipeId: recipeToEdit.id, title: title, ... dll)
            print("Update ditekan untuk resep: \(title)")
            dismiss()
        }) {
            Text("Update Recipe")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(mutedTeal)
                .cornerRadius(16)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
        .background(
            LinearGradient(gradient: Gradient(colors: [bgYellow.opacity(0), bgYellow]), startPoint: .top, endPoint: .bottom)
        )
    }
}

// MARK: - Preview
#Preview {
    RecipeEditView(recipe: Recipe.mockRecipes[0])
}

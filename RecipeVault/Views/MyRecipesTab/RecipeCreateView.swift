//
//  RecipeCreateView.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//

import SwiftUI
import PhotosUI

// MARK: - Recipe Create View
struct RecipeCreateView: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var viewModel: RecipeViewModel
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategories: Set<String> = []
    @State private var ingredients: [String] = [""]
    @State private var steps: [String] = [""]
    
    @State private var photoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var rawImageData: Data?
    
    let categories = ["Beef", "Chicken", "Lamb", "Seafood", "Pasta", "Vegetarian", "Dessert", "Vegan", "Pork", "Side", "Starter", "Breakfast", "Soup", "Spicy", "Gluten-Free", "Dairy-Free", "Miscellaneous"]
    
    let bgYellow = Color(hex: "f8fae5")
    let burntOrange = Color(hex: "cd4b12")
    let mutedTeal = Color(hex: "43766c")
    
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
            .navigationTitle("New Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(burntOrange)
                        .font(.merriweather(16, weight: .bold))
                }
            }
            .overlay(alignment: .bottom) {
                saveButton
            }
            .alert("Upload Failed", isPresented: Binding(
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

// MARK: - View Components
extension RecipeCreateView {
    // MARK: - Photo Upload Section With Conditional UI Based On Whether An Image Is Selected
    private var photoUploadSection: some View {
        PhotosPicker(selection: $photoItem, matching: .images, photoLibrary: .shared()) {
            if let selectedImage {
                Image(uiImage: selectedImage).resizable().scaledToFill().frame(height: 180).frame(maxWidth: .infinity).clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "photo.badge.plus").font(.system(size: 32))
                    Text("Add Recipe Photo").font(.merriweather(16, weight: .bold))
                    Text("Tap to upload").font(.merriweather(12, weight: .regular))
                }
                .foregroundColor(mutedTeal).frame(maxWidth: .infinity).padding(.vertical, 40).background(Color.white).cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(mutedTeal.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [8])))
            }
        }
        .onChange(of: photoItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                    self.selectedImage = image
                    self.rawImageData = image.jpegData(compressionQuality: 0.2)
                }
            }
        }
    }
    
    // MARK: - Reusable Input Section For Title And Other Simple Text Fields
    private func inputSection(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.merriweather(12, weight: .bold)).foregroundColor(.gray)
            TextField(placeholder, text: text).padding(16).background(Color.white).cornerRadius(12).font(.merriweather(14, weight: .regular))
        }
    }
    
    // MARK: - Description Section With Placeholder Logic Using ZStack And TextEditor
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DESCRIPTION").font(.merriweather(12, weight: .bold)).foregroundColor(.gray)
            ZStack(alignment: .topLeading) {
                if description.isEmpty {
                    Text("e.g. Share the story behind this recipe...")
                        .foregroundColor(Color(UIColor.placeholderText))
                        .font(.merriweather(14, weight: .regular))
                        .padding(.horizontal, 16).padding(.vertical, 16)
                }
                TextEditor(text: $description).font(.merriweather(14, weight: .regular)).padding(8).scrollContentBackground(.hidden)
            }
            .frame(minHeight: 120).background(Color.white).cornerRadius(12)
        }
    }
    
    // MARK: - Category Selection With Flow Layout And Multi-Select Logic
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
    
    // MARK: - Dynamic List Section For Ingredients And Steps
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
    
    // MARK: - Save Button With Loading State And Validation
    private var saveButton: some View {
        Button(action: {
            Task {
                let catString = selectedCategories.joined(separator: ", ")
                
                let success = await viewModel.createRecipe(title: title, description: description, category: catString, ingredients: ingredients, steps: steps, imageData: rawImageData)
                
                if success { dismiss() }
            }
        }) {
            HStack {
                if viewModel.isLoading { ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)).padding(.trailing, 8) }
                Text(viewModel.isLoading ? "Saving..." : "Save Recipe").font(.merriweather(16, weight: .bold)).foregroundColor(.white)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 16).background(mutedTeal).cornerRadius(16)
        }
        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isLoading)
        .padding(.horizontal, 20).padding(.bottom, 10)
        .background(LinearGradient(gradient: Gradient(colors: [bgYellow.opacity(0), bgYellow]), startPoint: .top, endPoint: .bottom))
    }
}

// MARK: - FlowLayout Component
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    // MARK: - Layout Protocol Methods
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    // MARK: - Core Logic For Placing Subviews In A Flow Layout
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.points[index].x, y: bounds.minY + result.points[index].y), proposal: .unspecified)
        }
    }
    
    // MARK: - Helper Struct To Calculate Positions And Total Size For Flow Layout
    struct FlowResult {
        var size: CGSize = .zero
        var points: [CGPoint] = []
        
        // MARK: - Innitializer To Calculate Positions For Each Subview And Total Size Based On Max Width
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0; var currentY: CGFloat = 0; var lineHeight: CGFloat = 0
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if currentX + size.width > maxWidth && currentX != 0 {
                    currentX = 0; currentY += lineHeight + spacing; lineHeight = 0
                }
                points.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing; lineHeight = max(lineHeight, size.height)
            }
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - Preview
#Preview {
    RecipeCreateView(viewModel: RecipeViewModel())
}

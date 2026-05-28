//
//  RecipeCreateView.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


// MARK: - RecipeCreateView
import SwiftUI

struct RecipeCreateView: View {
    
    // MARK: - Properties
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory = ""
    @State private var ingredients: [String] = [""]
    @State private var steps: [String] = [""]
    
    let categories = ["Beef", "Chicken", "Lamb", "Seafood", "Pasta", "Vegetarian", "Dessert", "Vegan"]
    
    // Theme Colors
    let bgYellow = Color(hex: "f8fae5")
    let burntOrange = Color(hex: "cd4b12")
    let mutedTeal = Color(hex: "43766c")
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    photoUploadSection
                    
                    inputSection(title: "RECIPE TITLE", placeholder: "e.g. Grandma's Lasagna", text: $title)
                    
                    inputSection(title: "DESCRIPTION", placeholder: "Share the story behind this recipe...", text: $description, isMultiLine: true)
                    
                    categorySection
                    
                    dynamicListSection(title: "INGREDIENTS", items: $ingredients, addPlaceholder: "Add Ingredient")
                    
                    dynamicListSection(title: "STEPS", items: $steps, addPlaceholder: "Add Step", isNumbered: true)
                    
                    // Spacer to ensure button isn't hidden behind safe area
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
                        .fontWeight(.bold)
                }
            }
            .overlay(alignment: .bottom) {
                saveButton
            }
        }
    }
}

// MARK: - Subviews
extension RecipeCreateView {
    
    private var photoUploadSection: some View {
        Button(action: {
            // TODO: Implement ImagePicker
        }) {
            VStack(spacing: 12) {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 32))
                Text("Add Recipe Photo")
                    .font(.headline)
                Text("Tap to upload")
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
    }
    
    private func inputSection(title: String, placeholder: String, text: Binding<String>, isMultiLine: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.gray)
            
            if isMultiLine {
                TextEditor(text: text)
                    .frame(height: 100)
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
            } else {
                TextField(placeholder, text: text)
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(12)
            }
        }
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CATEGORY")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.gray)
            
            // Flow Layout (Wrapping HStack)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            Text(category)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(selectedCategory == category ? burntOrange : Color.white)
                                .foregroundColor(selectedCategory == category ? .white : burntOrange)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(burntOrange.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                }
            }
        }
    }
    
    private func dynamicListSection(title: String, items: Binding<[String]>, addPlaceholder: String, isNumbered: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.gray)
            
            VStack(spacing: 0) {
                ForEach(0..<items.wrappedValue.count, id: \.self) { index in
                    HStack {
                        if isNumbered {
                            Circle()
                                .fill(mutedTeal)
                                .frame(width: 24, height: 24)
                                .overlay(Text("\(index + 1)").font(.caption.bold()).foregroundColor(.white))
                        } else {
                            Circle()
                                .fill(mutedTeal.opacity(0.5))
                                .frame(width: 12, height: 12)
                        }
                        
                        TextField("Describe...", text: items[index])
                            .padding(.leading, 8)
                        
                        Spacer()
                        
                        Button(action: {
                            items.wrappedValue.remove(at: index)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red.opacity(0.7))
                        }
                    }
                    .padding()
                    .background(Color.white)
                    // Add divider except for last item
                    Divider().padding(.horizontal)
                }
                
                // Add Button
                Button(action: {
                    items.wrappedValue.append("")
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text(addPlaceholder)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .foregroundColor(mutedTeal)
                    .padding()
                    .background(Color.white)
                }
            }
            .cornerRadius(16)
        }
    }
    
    private var saveButton: some View {
        Button(action: {
            // TODO: Call RecipeService to save
            dismiss()
        }) {
            Text("Save Recipe")
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
    RecipeCreateView()
}

// MARK: - Local Color Extension
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

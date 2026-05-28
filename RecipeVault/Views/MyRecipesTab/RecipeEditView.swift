//
//  RecipeEditView.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


// MARK: - RecipeEditView
import SwiftUI

struct RecipeEditView: View {
    
    // MARK: - Properties
    @Environment(\.dismiss) var dismiss
    
    // Parameter resep yang akan diedit
    let recipeToEdit: Recipe
    
    @State private var title: String
    @State private var description: String
    @State private var selectedCategory: String
    @State private var ingredients: [String]
    @State private var steps: [String]
    
    // Inisialisasi State dengan data lama
    init(recipe: Recipe) {
        self.recipeToEdit = recipe
        _title = State(initialValue: recipe.title)
        _description = State(initialValue: recipe.description)
        _selectedCategory = State(initialValue: recipe.category)
        _ingredients = State(initialValue: recipe.ingredients)
        _steps = State(initialValue: recipe.steps)
    }
    
    // Theme Colors
    let bgYellow = Color(hex: "f8fae5")
    let burntOrange = Color(hex: "cd4b12")
    let mutedTeal = Color(hex: "43766c")
    
    // MARK: - Body
    // (Isi Body dan Subviews di sini sama persis dengan RecipeCreateView, 
    // hanya judul NavigationTitle yang diubah menjadi "Edit Recipe" dan 
    // fungsi tombol save-nya memanggil updateRecipe).
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("Form Edit Identik dengan Create View...")
                    .padding()
                // Masukkan logika UI form dari RecipeCreateView di sini
            }
            .background(bgYellow.ignoresSafeArea())
            .navigationTitle("Edit Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(burntOrange)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    RecipeEditView(recipe: Recipe.mockRecipes[0])
}


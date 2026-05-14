//
//  RecipeViewModel.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 14/05/26.
//

import Foundation
import SwiftUI
import Combine

class RecipeViewModel: ObservableObject {
    // Published properties with sensible defaults to satisfy initialization
    @Published var recipeId: Int
    @Published var title: String
    @Published var ingredients: String
    @Published var steps: String
    @Published var image: String

    // Designated initializer
    init(recipeId: Int = 0,
         title: String = "",
         ingredients: String = "",
         steps: String = "",
         image: String = "") {
        self.recipeId = recipeId
        self.title = title
        self.ingredients = ingredients
        self.steps = steps
        self.image = image
    }

    // MARK: - Count Recipe Collection Function
    func countCollections(id: Int) {
        
    }
}


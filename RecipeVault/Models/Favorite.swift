//
//  Favorite.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 27/05/26.
//


import Foundation
import FirebaseFirestore

struct Favorite: Codable, Identifiable {
    @DocumentID var id: String? // Acts as the favoriteId
    var recipeId: String
    var userId: String
    var recipeSource: String // E.g., "MealDB" or "Personal"
    @ServerTimestamp var savedAt: Date?
}
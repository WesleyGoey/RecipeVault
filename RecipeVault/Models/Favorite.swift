//
//  Favorite.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 27/05/26.
//


import Foundation
import FirebaseFirestore

// MARK: - Favorite Model
struct Favorite: Codable, Identifiable {
    @DocumentID var id: String?
    var recipeId: String
    var userId: String
    var recipeSource: String
    @ServerTimestamp var savedAt: Date?
}

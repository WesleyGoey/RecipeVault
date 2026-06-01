//
//  Recipe.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 27/05/26.
//


import Foundation
import FirebaseFirestore

// MARK: - Recipe Model
struct Recipe: Codable, Identifiable, Equatable {
    @DocumentID var id: String?
    var userId: String
    var title: String
    var description: String
    var ingredients: [String]
    var steps: [String]
    var category: String
    var recipeImage: String
    @ServerTimestamp var createdAt: Date?
    
    // MARK: - Check Ownership
    func isOwnedBy(currentUserId: String) -> Bool {
        return userId == currentUserId
    }
}

//
//  Recipe.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 27/05/26.
//


import Foundation
import FirebaseFirestore

struct Recipe: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var title: String
    var description: String
    var ingredients: [String]
    var steps: [String]
    var category: String
    var recipeImage: String
    @ServerTimestamp var createdAt: Date? // Firebase will automatically set the exact server time!
    
    // Helper method from your class diagram
    func isOwnedBy(currentUserId: String) -> Bool {
        return userId == currentUserId
    }
}

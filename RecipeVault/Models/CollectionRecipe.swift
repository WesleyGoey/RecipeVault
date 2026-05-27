//
//  CollectionRecipe.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 27/05/26.
//


import Foundation
import FirebaseFirestore

struct CollectionRecipe: Codable, Identifiable {
    @DocumentID var id: String?
    var collectionId: String
    var recipeId: String
    @ServerTimestamp var addedAt: Date?
}
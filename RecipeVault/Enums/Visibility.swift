//
//  Visibility.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 27/05/26.
//


import Foundation
import FirebaseFirestore

// MARK: - Visibility
enum Visibility: String, Codable {
    case publicVisibility = "PUBLIC"
    case privateVisibility = "PRIVATE"
}

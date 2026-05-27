//
//  User.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 14/05/26.
//

import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    @DocumentID var id: String? // Automatically grabs the Firestore Document ID (which is the uid)
    var name: String
    var email: String
    var profilePicture: String
    
    // Optional helper to convert to dictionary if needed for your Service Layer
    func toDict() -> [String: Any] {
        return [
            "name": name,
            "email": email,
            "profilePicture": profilePicture
        ]
    }
}

//
//  User.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 14/05/26.
//

import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var email: String
    var profilePicture: String
    
    func toDict() -> [String: Any] {
        return [
            "name": name,
            "email": email,
            "profilePicture": profilePicture
        ]
    }
}

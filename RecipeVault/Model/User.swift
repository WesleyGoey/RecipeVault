//
//  User.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 14/05/26.
//

import Foundation
import FirebaseDatabase

struct User: Identifiable {
    var id = UUID()
    var name: String
    var email: String
    var passwordHash: String
}

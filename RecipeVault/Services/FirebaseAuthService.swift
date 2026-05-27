//
//  FirebaseAuthService.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 28/05/26.
//


import Foundation
import FirebaseAuth

class FirebaseAuthService {
    static let shared = FirebaseAuthService() // Singleton pattern
    
    // Register a new user with Firebase Auth
    func register(email: String, password: String) async throws -> String {
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return authResult.user.uid
    }
    
    // Log in an existing user
    func login(email: String, password: String) async throws -> String {
        let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return authResult.user.uid
    }
    
    // Log out
    func logout() throws {
        try Auth.auth().signOut()
    }
    
    // Get current logged-in UID
    func getCurrentUID() -> String? {
        return Auth.auth().currentUser?.uid
    }
}
//
//  AuthRepository.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation
import FirebaseAuth

// MARK: - AuthRepository Class
class AuthRepository: AuthRepositoryProtocol {
    static let shared = AuthRepository()
    
    // MARK: - Initializer
    private init() {}
    
    // MARK: - Register
    func register(email: String, password: String) async throws -> String {
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return authResult.user.uid
    }
    
    // MARK: - Login
    func login(email: String, password: String) async throws -> String {
        let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return authResult.user.uid
    }
    
    // MARK: - Logout
    func logout() throws {
        try Auth.auth().signOut()
    }
    
    // MARK: - Get Current UID
    func getCurrentUID() -> String? {
        return Auth.auth().currentUser?.uid
    }
}

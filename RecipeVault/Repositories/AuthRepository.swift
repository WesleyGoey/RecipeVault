//
//  AuthRepository.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


// MARK: - AuthRepository
import Foundation
import FirebaseAuth

class AuthRepository: AuthRepositoryProtocol {
    
    // MARK: - Properties
    static let shared = AuthRepository()
    
    // MARK: - Initializer
    private init() {}
    
    // MARK: - Methods
    func register(email: String, password: String) async throws -> String {
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return authResult.user.uid
    }
    
    func login(email: String, password: String) async throws -> String {
        let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return authResult.user.uid
    }
    
    func logout() throws {
        try Auth.auth().signOut()
    }
    
    func getCurrentUID() -> String? {
        return Auth.auth().currentUser?.uid
    }
}
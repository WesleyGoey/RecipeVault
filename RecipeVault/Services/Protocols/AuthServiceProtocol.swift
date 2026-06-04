//
//  AuthServiceProtocol.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation

// MARK: - AuthService Protocol
protocol AuthServiceProtocol {
    // MARK: - Register And Create Profile
    func registerAndCreateProfile(name: String, email: String, password: String) async throws -> String
    
    // MARK: - Login
    func login(email: String, password: String) async throws -> String
    
    // MARK: - Logout
    func logout() throws
    
    // MARK: - Get Current UID
    func getCurrentUID() -> String?
}

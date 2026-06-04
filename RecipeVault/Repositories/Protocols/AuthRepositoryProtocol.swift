//
//  AuthRepositoryProtocol.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation

// MARK: - AuthRepository Protocol
protocol AuthRepositoryProtocol {
    // MARK: - Register Account
    func register(email: String, password: String) async throws -> String
    
    // MARK: - Login Account
    func login(email: String, password: String) async throws -> String
    
    // MARK: - Logout Session
    func logout() throws
    
    // MARK: - Get Current User UID
    func getCurrentUID() -> String?
}

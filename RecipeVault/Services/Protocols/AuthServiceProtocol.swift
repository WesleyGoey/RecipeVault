//
//  AuthServiceProtocol.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


// MARK: - AuthServiceProtocol
import Foundation

protocol AuthServiceProtocol {
    func registerAndCreateProfile(name: String, email: String, password: String) async throws -> String
    func login(email: String, password: String) async throws -> String
    func logout() throws
    func getCurrentUID() -> String?
}
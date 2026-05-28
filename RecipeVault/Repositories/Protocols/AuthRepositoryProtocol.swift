//
//  AuthRepositoryProtocol.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


// MARK: - AuthRepositoryProtocol
import Foundation

protocol AuthRepositoryProtocol {
    func register(email: String, password: String) async throws -> String
    func login(email: String, password: String) async throws -> String
    func logout() throws
    func getCurrentUID() -> String?
}
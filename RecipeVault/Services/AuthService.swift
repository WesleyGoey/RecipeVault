//
//  AuthService.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


import Foundation

// MARK: - AuthService Class
class AuthService: AuthServiceProtocol {
    static let shared = AuthService(authRepo: AuthRepository.shared, firestoreRepo: FirestoreRepository.shared)
    private let authRepo: AuthRepositoryProtocol
    private let firestoreRepo: FirestoreRepositoryProtocol
    
    // MARK: - Initializer
    init(authRepo: AuthRepositoryProtocol, firestoreRepo: FirestoreRepositoryProtocol) {
        self.authRepo = authRepo
        self.firestoreRepo = firestoreRepo
    }
    
    // MARK: - Register And Create Profile
    func registerAndCreateProfile(name: String, email: String, password: String) async throws -> String {
        let uid = try await authRepo.register(email: email, password: password)
        try await firestoreRepo.saveUserProfile(userId: uid, name: name, email: email, profilePicture: "")
        return uid
    }
    
    // MARK: - Login
    func login(email: String, password: String) async throws -> String {
        return try await authRepo.login(email: email, password: password)
    }
    
    // MARK: - Logout
    func logout() throws {
        try authRepo.logout()
    }
    
    // MARK: - Get Current UID
    func getCurrentUID() -> String? {
        return authRepo.getCurrentUID()
    }
}

//
//  AuthService.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


// MARK: - AuthService
import Foundation

class AuthService: AuthServiceProtocol {
    
    // MARK: - Properties
    static let shared = AuthService(authRepo: AuthRepository.shared, firestoreRepo: FirestoreRepository.shared)
    
    private let authRepo: AuthRepositoryProtocol
    private let firestoreRepo: FirestoreRepositoryProtocol
    
    // MARK: - Initializer (Dependency Injection)
    init(authRepo: AuthRepositoryProtocol, firestoreRepo: FirestoreRepositoryProtocol) {
        self.authRepo = authRepo
        self.firestoreRepo = firestoreRepo
    }
    
    // MARK: - Methods
    func registerAndCreateProfile(name: String, email: String, password: String) async throws -> String {
        // 1. Daftarkan akun di Authentication
        let uid = try await authRepo.register(email: email, password: password)
        
        // 2. Simpan profil ke database Firestore
        try await firestoreRepo.saveUserProfile(userId: uid, name: name, email: email, profilePicture: "")
        
        return uid
    }
    
    func login(email: String, password: String) async throws -> String {
        return try await authRepo.login(email: email, password: password)
    }
    
    func logout() throws {
        try authRepo.logout()
    }
    
    func getCurrentUID() -> String? {
        return authRepo.getCurrentUID()
    }
}
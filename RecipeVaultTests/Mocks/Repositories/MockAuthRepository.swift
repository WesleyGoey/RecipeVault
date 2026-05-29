//
//  MockAuthRepository.swift
//  RecipeVault
//
//  Created by Wesley Goey on 29/05/26.
//


// MARK: - MockAuthRepository
import Foundation
@testable import RecipeVault // Sesuaikan dengan nama modul utamamu

class MockAuthRepository: AuthRepositoryProtocol {
    
    // MARK: - Test Control Properties
    var mockedUID: String? = "mock_uid_123"
    var shouldThrowError = false
    
    // MARK: - Method Call Trackers
    var isRegisterCalled = false
    var isLoginCalled = false
    var isLogoutCalled = false
    var isGetCurrentUIDCalled = false
    
    // MARK: - Protocol Methods
    func register(email: String, password: String) async throws -> String {
        isRegisterCalled = true
        if shouldThrowError {
            throw NSError(domain: "FirebaseAuthError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Email already in use."])
        }
        return mockedUID ?? UUID().uuidString
    }
    
    func login(email: String, password: String) async throws -> String {
        isLoginCalled = true
        if shouldThrowError {
            throw NSError(domain: "FirebaseAuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials."])
        }
        return mockedUID ?? UUID().uuidString
    }
    
    func logout() throws {
        isLogoutCalled = true
        if shouldThrowError {
            throw NSError(domain: "FirebaseAuthError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to sign out."])
        }
    }
    
    func getCurrentUID() -> String? {
        isGetCurrentUIDCalled = true
        return mockedUID
    }
}

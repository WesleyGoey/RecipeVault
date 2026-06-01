//
//  AuthViewModel.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 28/05/26.
//


import Foundation
import SwiftUI
import Combine

// MARK: - AuthViewModel Class
@MainActor
class AuthViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    
    @Published var errorMessage = ""
    @Published var isLoading = false
    
    @Published var currentUserId: String? = AuthService.shared.getCurrentUID()
    
    var isLoggedIn: Bool {
        currentUserId != nil
    }
    
    // MARK: - Login
    func login() async {
        isLoading = true
        errorMessage = ""
        
        do {
            let uid = try await AuthService.shared.login(email: email, password: password)
            self.currentUserId = uid
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Register
    func register() async {
        isLoading = true
        errorMessage = ""
        
        do {
            let uid = try await AuthService.shared.registerAndCreateProfile(name: name, email: email, password: password)
            self.currentUserId = uid
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Logout
    func logout() {
        do {
            try AuthService.shared.logout()
            self.currentUserId = nil
            self.email = ""
            self.password = ""
            self.name = ""
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}

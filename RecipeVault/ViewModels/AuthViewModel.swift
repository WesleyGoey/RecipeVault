//
//  AuthViewModel.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 28/05/26.
//


// MARK: - AuthViewModel
import Foundation
import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    // MARK: - Inputs (Bound to TextFields in the View)
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    
    // MARK: - UI State
    @Published var errorMessage = ""
    @Published var isLoading = false
    
    // MARK: - App Session State
    @Published var currentUserId: String? = AuthService.shared.getCurrentUID()
    
    var isLoggedIn: Bool {
        currentUserId != nil
    }
    
    // MARK: - Actions
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
    
    func register() async {
        isLoading = true
        errorMessage = ""
        
        do {
            // Eksekusi Auth & Pembuatan Profil hanya dengan 1 baris kode yang bersih!
            let uid = try await AuthService.shared.registerAndCreateProfile(name: name, email: email, password: password)
            self.currentUserId = uid
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
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

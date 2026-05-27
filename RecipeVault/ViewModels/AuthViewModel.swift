//
//  AuthViewModel.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 28/05/26.
//

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
    // Checks if someone is already logged in when the app opens
    @Published var currentUserId: String? = FirebaseAuthService.shared.getCurrentUID()
    
    var isLoggedIn: Bool {
        currentUserId != nil
    }
    
    // MARK: - Actions
    func login() async {
        isLoading = true
        errorMessage = ""
        
        do {
            let uid = try await FirebaseAuthService.shared.login(email: email, password: password)
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
            // 1. Create the Auth Account via the Service
            let uid = try await FirebaseAuthService.shared.register(email: email, password: password)
            
            // 2. Save the Profile Data to Firestore via the Service
            try await FirestoreService.shared.saveUserProfile(userId: uid, name: name, email: email)
            
            // 3. Update the state to log the user into the app
            self.currentUserId = uid
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func logout() {
        do {
            try FirebaseAuthService.shared.logout()
            self.currentUserId = nil
            // Clear out form fields on logout
            self.email = ""
            self.password = ""
            self.name = ""
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}

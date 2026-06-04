//
//  ProfileViewModel.swift
//  RecipeVault
//
//  Created by Kristoforus Bertrand Wahyudi on 29/05/26.
//


import Foundation
import SwiftUI
import FirebaseAuth
import Combine
import FirebaseFirestore

// MARK: - ProfileViewModel Class
@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var userId: String = ""
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var profilePictureURL: String = ""
    
    @Published var selectedUIImage: UIImage? = nil
    @Published var selectedImageData: Data? = nil
    @Published var isImageDeleted: Bool = false
    
    @Published var publicCollections: [RecipeCollection] = []
    @Published var collectionCounts: [String: Int] = [:]
    @Published var favoriteRecipes: [Recipe] = []
    @Published var authorNamesCache: [String: String] = [:]
    
    @Published var isLoading: Bool = false
    @Published var operationError: String = ""
    @Published var showingEditProfile: Bool = false
    
    @Published var oldPassword: String = ""
    @Published var newPassword: String = ""
    @Published var confirmNewPassword: String = ""
    
    private let profileService = ProfileService.shared
    private let collectionService = CollectionService.shared
    private let recipeService = RecipeService.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Task { await initializeUserProfile() }
        
        NotificationCenter.default.publisher(for: .favoritesUpdated)
            .sink { [weak self] _ in
                Task {
                    await self?.loadFavoriteRecipes()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Initialize User Profile
    func initializeUserProfile() async {
        if let uid = Auth.auth().currentUser?.uid {
            self.userId = uid
            await loadUserProfile(uid: uid)
            await loadPublicCollections()
            await loadFavoriteRecipes()
        }
    }
    
    func clearError() {
        self.operationError = ""
    }
    
    // MARK: - 👤 Profile CRUD Methods
    func loadUserProfile(uid: String) async {
        do {
            if let data = try await profileService.getUserProfile(userId: uid) {
                self.name = data["name"] as? String ?? ""
                self.email = data["email"] as? String ?? ""
                self.profilePictureURL = data["profilePicture"] as? String ?? ""
            }
        } catch {
            print("Failed loading user profile:", error)
        }
    }
    
    // MARK: - Save Profile Changes
    func saveProfileChanges() async {
        guard !userId.isEmpty else { return }
        isLoading = true
        operationError = ""
        
        do {
            let finalCurrentURL = isImageDeleted ? "" : profilePictureURL
            
            let updatedURL = try await profileService.saveUserProfile(
                userId: userId,
                name: name,
                email: email,
                currentImageURL: finalCurrentURL,
                newImageData: selectedImageData
            )
            
            self.profilePictureURL = updatedURL
            self.showingEditProfile = false
            self.isImageDeleted = false
        } catch {
            self.operationError = "Fail to save profile: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Change Password
    func changePassword() async {
        guard let user = Auth.auth().currentUser else {
            operationError = "Tidak ada user yang login."
            return
        }
        
        if newPassword != confirmNewPassword {
            operationError = "Password baru dan konfirmasi tidak cocok."
            return
        }
        if newPassword.count < 8 {
            operationError = "Password baru minimal 8 karakter."
            return
        }
        
        isLoading = true
        operationError = ""
        
        do {
            guard let email = user.email, !oldPassword.isEmpty else {
                operationError = "Masukkan password lama untuk verifikasi."
                isLoading = false
                return
            }
            let credential = EmailAuthProvider.credential(withEmail: email, password: oldPassword)
            _ = try await user.reauthenticate(with: credential)
            try await user.updatePassword(to: newPassword)
        } catch {
            operationError = "Fail to change password: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Load Public Collections
    func loadPublicCollections() async {
        guard !userId.isEmpty else { return }
        isLoading = true
        operationError = ""
        
        do {
            let allUserCollections = try await collectionService.getUserCollections(userId: userId)
            self.publicCollections = allUserCollections.filter { $0.visibility == .publicVisibility }
            
            for col in self.publicCollections {
                if let cid = col.id {
                    let count = (try? await collectionService.getRecipeCountInCollection(collectionId: cid)) ?? 0
                    self.collectionCounts[cid] = count
                }
            }
        } catch {
            self.operationError = "Gagal memuat koleksi: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    // MARK: - Load Favorite Recipes
    func loadFavoriteRecipes() async {
        guard !userId.isEmpty else { return }
        isLoading = true
        operationError = ""
        
        do {
            self.favoriteRecipes = try await recipeService.getFavoriteRecipes(userId: userId)
        } catch {
            self.operationError = "Fail to load favorite recipe: \(error.localizedDescription)"
            self.favoriteRecipes = []
        }
        isLoading = false
    }
    
    // MARK: - Fetch Author Name
    func fetchAuthorName(for recipeUserId: String) async -> String {
        if recipeUserId == "themealdb" { return "TheMealDB" }
        if recipeUserId == Auth.auth().currentUser?.uid { return "Me" }
        if let cachedName = authorNamesCache[recipeUserId] { return cachedName }
        
        do {
            if let data = try await profileService.getUserProfile(userId: recipeUserId),
               let name = data["name"] as? String {
                self.authorNamesCache[recipeUserId] = name
                return name
            }
        } catch {
            print("Gagal mengambil nama author: \(error)")
        }
        return "Community User"
    }
}

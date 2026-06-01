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

@MainActor
final class ProfileViewModel: ObservableObject {
    // MARK: - User State
    @Published var userId: String = ""
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var profilePictureURL: String = "" // Ini berisi teks Base64
    
    // 🚀 STATE UNTUK EDIT FOTO
    @Published var selectedUIImage: UIImage? = nil
    @Published var selectedImageData: Data? = nil
    @Published var isImageDeleted: Bool = false // <-- WAJIB ADA UNTUK FITUR TRASH
    
    // MARK: - Content State
    @Published var publicCollections: [RecipeCollection] = []
    @Published var collectionCounts: [String: Int] = [:]
    @Published var favoriteRecipes: [Recipe] = []
    @Published var authorNamesCache: [String: String] = [:]
    
    // MARK: - UI & Form State
    @Published var isLoading: Bool = false
    @Published var operationError: String = ""
    @Published var showingEditProfile: Bool = false
    
    @Published var oldPassword: String = ""
    @Published var newPassword: String = ""
    @Published var confirmNewPassword: String = ""
    
    // MARK: - Services
    private let profileService = ProfileService.shared
    private let collectionService = CollectionService.shared
    private let recipeService = RecipeService.shared
    
    init() {
        Task { await initializeUserProfile() }
    }
    
    func initializeUserProfile() async {
        if let uid = Auth.auth().currentUser?.uid {
            self.userId = uid
            await loadUserProfile(uid: uid)
            await loadPublicCollections()
            await loadFavoriteRecipes()
        }
    }
    
    // MARK: - 👤 Profile CRUD Methods
    func loadUserProfile(uid: String) async {
        do {
            if let data = try await profileService.getUserProfile(userId: uid) {
                self.name = data["name"] as? String ?? ""
                self.email = data["email"] as? String ?? ""
                // Pastikan key-nya "profilePicture" sesuai dengan di FirestoreRepository
                self.profilePictureURL = data["profilePicture"] as? String ?? ""
            }
        } catch {
            print("Failed loading user profile:", error)
        }
    }
    
    func saveProfileChanges() async {
        guard !userId.isEmpty else { return }
        isLoading = true
        operationError = ""
        
        do {
            // 🚀 LOGIKA TRASH: Jika dihapus, kirim URL/Base64 kosong ke Service
            let finalCurrentURL = isImageDeleted ? "" : profilePictureURL
            
            let updatedURL = try await profileService.saveUserProfile(
                userId: userId,
                name: name,
                email: email,
                currentImageURL: finalCurrentURL,
                newImageData: selectedImageData // Ingat: Di ProfileService harus pakai Base64Helper / encode ya
            )
            
            self.profilePictureURL = updatedURL
            self.showingEditProfile = false
            self.isImageDeleted = false // Reset state
        } catch {
            self.operationError = "Gagal menyimpan profil: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Password
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
            operationError = "Gagal mengganti password: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
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
    
    func loadFavoriteRecipes() async {
        guard !userId.isEmpty else { return }
        isLoading = true
        operationError = ""
        
        do {
            self.favoriteRecipes = try await recipeService.getFavoriteRecipes(userId: userId)
        } catch {
            self.operationError = "Gagal memuat favorit: \(error.localizedDescription)"
            self.favoriteRecipes = []
        }
        isLoading = false
    }
    
    func fetchAuthorName(for recipeUserId: String) async -> String {
        if recipeUserId == "themealdb" { return "TheMealDB" }
        if recipeUserId == Auth.auth().currentUser?.uid { return "Me" }
        if let cachedName = authorNamesCache[recipeUserId] { return cachedName }
        
        do {
            let doc = try await Firestore.firestore().collection("users").document(recipeUserId).getDocument()
            if let name = doc.data()?["name"] as? String {
                self.authorNamesCache[recipeUserId] = name
                return name
            }
        } catch {
            print("Gagal mengambil nama author: \(error)")
        }
        return "Community User"
    }
}

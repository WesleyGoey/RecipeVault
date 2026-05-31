//
//  RecipeViewModel.swift
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
    @Published var profilePictureURL: String = ""
    @Published var selectedUIImage: UIImage? = nil
    @Published var selectedImageData: Data? = nil
    
    // MARK: - Content State
    @Published var publicCollections: [RecipeCollection] = [] // 🚀 Hanya menyimpan yang public
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
            await loadPublicCollections() // 🚀 Panggil nama fungsi yang baru
            await loadFavoriteRecipes()   // 🚀 Panggil nama fungsi yang baru
        }
    }
    
    // MARK: - 👤 Profile CRUD Methods
    func loadUserProfile(uid: String) async {
        do {
            // 🚀 SEKARANG MEMANGGIL PROFILE SERVICE
            if let data = try await profileService.getUserProfile(userId: uid) {
                self.name = data["name"] as? String ?? ""
                self.email = data["email"] as? String ?? ""
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
            // 🚀 LOGIKA UPLOAD & SAVE SEKARANG DIURUS OLEH SERVICE
            let updatedURL = try await profileService.saveUserProfile(
                userId: userId,
                name: name,
                email: email,
                currentImageURL: profilePictureURL,
                newImageData: selectedImageData
            )
            
            self.profilePictureURL = updatedURL
            self.showingEditProfile = false
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
    
    // 🚀 Hanya mengambil koleksi yang Public
    func loadPublicCollections() async {
        guard !userId.isEmpty else { return }
        isLoading = true
        operationError = ""
        
        do {
            // Mengambil semua koleksi milik user ini
            let allUserCollections = try await collectionService.getUserCollections(userId: userId)
            // Memfilter hanya yang public
            self.publicCollections = allUserCollections.filter { $0.visibility == .publicVisibility }
            
            // Menghitung jumlah resep untuk setiap koleksi public
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
    
    // 🚀 Mengambil resep favorit
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
        // 1. Cek aturan statis (TheMealDB)
        if recipeUserId == "themealdb" { return "TheMealDB" }
        
        // 2. Cek apakah itu diri kita sendiri
        if recipeUserId == Auth.auth().currentUser?.uid { return "Me" }
        
        // 3. Cek apakah namanya sudah ada di Cache memori kita
        if let cachedName = authorNamesCache[recipeUserId] {
            return cachedName
        }
        
        // 4. Jika belum ada, baru kita tarik dari Firestore (HANYA 1X PER USER)
        do {
            let doc = try await Firestore.firestore().collection("users").document(recipeUserId).getDocument()
            if let name = doc.data()?["name"] as? String {
                self.authorNamesCache[recipeUserId] = name // Simpan ke cache
                return name
            }
        } catch {
            print("Gagal mengambil nama author: \(error)")
        }
        
        return "Community User"
    }
}

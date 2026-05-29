//
// ProfileViewModel.swift
// RecipeVault
//

import Foundation
import SwiftUI
import FirebaseAuth
import Combine
import FirebaseFirestore

@MainActor
final class ProfileViewModel: ObservableObject {
    // user/profile
    @Published var userId: String = ""
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var profilePictureURL: String = ""
    @Published var selectedUIImage: UIImage? = nil
    @Published var selectedImageData: Data? = nil

    // collections & favorites
    @Published var collections: [RecipeCollection] = []
    @Published var collectionCounts: [String: Int] = [:] // key: collectionId
    @Published var favoriteRecipes: [Recipe] = []

    // create collection sheet state used by ProfileView.swift
    @Published var showingCreateSheet: Bool = false
    @Published var newCollectionName: String = ""
    @Published var newCollectionDescription: String = ""
    @Published var newVisibility: Visibility = .publicVisibility

    // UI state
    @Published var isLoading: Bool = false
    @Published var operationError: String = ""
    @Published var showingEditProfile: Bool = false

    // password fields (for change)
    @Published var oldPassword: String = ""
    @Published var newPassword: String = ""
    @Published var confirmNewPassword: String = ""

    private let db = Firestore.firestore()

    init() {
        Task { await initializeUserProfile() }
    }

    func initializeUserProfile() async {
        if let uid = Auth.auth().currentUser?.uid {
            userId = uid
            await loadUserProfile(uid: uid)
            await loadCollections()
            await loadFavorites()
        }
    }

    // MARK: - User profile
    func loadUserProfile(uid: String) async {
        do {
            let doc = try await db.collection("users").document(uid).getDocument()
            if let data = doc.data() {
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
        var uploadedURL = profilePictureURL

        do {
            if let data = selectedImageData {
                // CloudStorageRepository.shared.uploadImage(...) is expected to exist
                uploadedURL = try await CloudStorageRepository.shared.uploadImage(image: data, path: "profiles")
            }
            try await FirestoreRepository.shared.saveUserProfile(userId: userId, name: name, email: email, profilePicture: uploadedURL)
            profilePictureURL = uploadedURL
        } catch {
            operationError = "Gagal menyimpan profil: \(error.localizedDescription)"
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

    // MARK: - Collections
    func loadCollections() async {
        guard !userId.isEmpty else { return }
        isLoading = true
        operationError = ""
        do {
            let docs = try await FirestoreRepository.shared.getUserCollections(userId: userId)
            self.collections = docs // docs is [RecipeCollection]
            // fetch counts for each collection
            for col in docs {
                if let cid = col.id {
                    Task { await self.loadRecipeCount(for: cid) }
                }
            }
        } catch {
            operationError = "Gagal memuat koleksi: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func loadRecipeCount(for collectionId: String) async {
        do {
            let query = try await db.collection("collection_recipes")
                .whereField("collectionId", isEqualTo: collectionId)
                .getDocuments()
            let count = query.documents.count
            DispatchQueue.main.async {
                self.collectionCounts[collectionId] = count
            }
        } catch {
            print("Failed loading count for \(collectionId):", error)
        }
    }

    func createCollection() async {
        guard !userId.isEmpty else { return }
        let nameTrimmed = newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !nameTrimmed.isEmpty else {
            operationError = "Nama koleksi tidak boleh kosong."
            return
        }

        isLoading = true
        operationError = ""
        do {
            let newCol = RecipeCollection(
                id: nil,
                userId: userId,
                name: nameTrimmed,
                description: newCollectionDescription,
                collectionImage: "",
                visibility: newVisibility,
                createdAt: nil
            )
            try await FirestoreRepository.shared.createCollection(collection: newCol)
            // reset input
            newCollectionName = ""
            newCollectionDescription = ""
            newVisibility = .publicVisibility
            showingCreateSheet = false
            await loadCollections()
        } catch {
            operationError = "Gagal membuat koleksi: \(error.localizedDescription)"
        }
        isLoading = false
    }

    // MARK: - Favorites
    func loadFavorites() async {
        guard !userId.isEmpty else { return }
        isLoading = true
        operationError = ""
        do {
            let favSnap = try await db.collection("favorites").whereField("userId", isEqualTo: userId).getDocuments()
            let recipeIds = favSnap.documents.compactMap { $0["recipeId"] as? String }
            var recipes: [Recipe] = []
            let chunkSize = 10
            for chunkStart in stride(from: 0, to: recipeIds.count, by: chunkSize) {
                let chunk = Array(recipeIds[chunkStart..<min(chunkStart+chunkSize, recipeIds.count)])
                if chunk.isEmpty { continue }
                let q = try await db.collection("recipes").whereField(FieldPath.documentID(), in: chunk).getDocuments()
                for d in q.documents {
                    if let r = try? d.data(as: Recipe.self) {
                        recipes.append(r)
                    } else {
                        let data = d.data()
                        let id = d.documentID
                        let recipe = Recipe(
                            id: id,
                            userId: data["userId"] as? String ?? "",
                            title: data["title"] as? String ?? "",
                            description: data["description"] as? String ?? "",
                            ingredients: data["ingredients"] as? [String] ?? [],
                            steps: data["steps"] as? [String] ?? [],
                            category: data["category"] as? String ?? "",
                            recipeImage: data["recipeImage"] as? String ?? "",
                            createdAt: nil
                        )
                        recipes.append(recipe)
                    }
                }
            }
            self.favoriteRecipes = recipes
        } catch {
            print("Failed loading favorites:", error)
            self.favoriteRecipes = []
        }
        isLoading = false
    }
}

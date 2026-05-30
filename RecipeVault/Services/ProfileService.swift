//
//  ProfileService.swift
//  RecipeVault
//
//  Created by Wesley Goey on 31/05/26.
//


import Foundation

class ProfileService: ProfileServiceProtocol {
    
    static let shared = ProfileService(
        firestoreRepo: FirestoreRepository.shared,
        storageRepo: CloudStorageRepository.shared
    )
    
    private let firestoreRepo: FirestoreRepositoryProtocol
    private let storageRepo: CloudStorageRepositoryProtocol
    
    init(firestoreRepo: FirestoreRepositoryProtocol, storageRepo: CloudStorageRepositoryProtocol) {
        self.firestoreRepo = firestoreRepo
        self.storageRepo = storageRepo
    }
    
    // MARK: - READ
    func getUserProfile(userId: String) async throws -> [String: Any]? {
        return try await firestoreRepo.getUserProfile(userId: userId)
    }
    
    // MARK: - UPDATE
    func saveUserProfile(userId: String, name: String, email: String, currentImageURL: String, newImageData: Data?) async throws -> String {
        var finalImageURL = currentImageURL
        
        // 1. Jika ada gambar baru yang dipilih, unggah dulu ke Storage
        if let data = newImageData {
            // Validasi ukuran gambar maksimal 5MB (Opsional tapi disarankan)
            let sizeInMB = Double(data.count) / (1024.0 * 1024.0)
            if sizeInMB > 5.0 {
                throw NSError(domain: "ProfileService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Ukuran gambar maksimal 5MB."])
            }
            
            finalImageURL = try await storageRepo.uploadImage(image: data, path: "profiles")
        }
        
        // 2. Simpan data profil beserta URL gambar (baru/lama) ke Firestore
        try await firestoreRepo.saveUserProfile(userId: userId, name: name, email: email, profilePicture: finalImageURL)
        
        // 3. Kembalikan URL terakhir agar ViewModel bisa memperbarui UI
        return finalImageURL
    }
}

//
//  ProfileService.swift
//  RecipeVault
//
//  Created by Wesley Goey on 31/05/26.
//

import Foundation
import UIKit

class ProfileService: ProfileServiceProtocol {
    
    // 🚀 EFISIENSI: Buang storageRepo karena kita menyimpan foto profil sebagai teks Base64 di Firestore
    static let shared = ProfileService(
        firestoreRepo: FirestoreRepository.shared
    )
    
    private let firestoreRepo: FirestoreRepositoryProtocol
    
    // Inisialisasi sekarang hanya membutuhkan FirestoreRepository
    init(firestoreRepo: FirestoreRepositoryProtocol) {
        self.firestoreRepo = firestoreRepo
    }
    
    // MARK: - READ
    func getUserProfile(userId: String) async throws -> [String: Any]? {
        return try await firestoreRepo.getUserProfile(userId: userId)
    }
    
    // MARK: - UPDATE
    func saveUserProfile(userId: String, name: String, email: String, currentImageURL: String, newImageData: Data?) async throws -> String {
        var finalBase64String = currentImageURL
        
        // Jika user memilih foto baru, koki (Service) mengonversinya menjadi Base64 yang aman (<150KB) lewat Helper
        if let data = newImageData, let uiImage = UIImage(data: data) {
            finalBase64String = Base64Helper.encode(uiImage) ?? ""
        }
        
        // Kirim teks matang ke gudang database (Repository)
        try await firestoreRepo.saveUserProfile(userId: userId, name: name, email: email, profilePicture: finalBase64String)
        
        return finalBase64String
    }
}

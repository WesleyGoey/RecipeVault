//
//  ProfileService.swift
//  RecipeVault
//
//  Created by Wesley Goey on 31/05/26.
//

import Foundation
import UIKit

// MARK: - ProfileService Class
class ProfileService: ProfileServiceProtocol {
    static let shared = ProfileService(
        firestoreRepo: FirestoreRepository.shared
    )
    private let firestoreRepo: FirestoreRepositoryProtocol
    
    // MARK: - Initializer
    init(firestoreRepo: FirestoreRepositoryProtocol) {
        self.firestoreRepo = firestoreRepo
    }
    
    // MARK: - Get User Profile
    func getUserProfile(userId: String) async throws -> [String: Any]? {
        return try await firestoreRepo.getUserProfile(userId: userId)
    }
    
    // MARK: - Save User Profile
    func saveUserProfile(userId: String, name: String, email: String, currentImageURL: String, newImageData: Data?) async throws -> String {
        var finalBase64String = currentImageURL
        
        if let data = newImageData, let uiImage = UIImage(data: data) {
            finalBase64String = Base64Helper.encode(uiImage) ?? ""
        }
        
        try await firestoreRepo.saveUserProfile(userId: userId, name: name, email: email, profilePicture: finalBase64String)
        
        return finalBase64String
    }
}

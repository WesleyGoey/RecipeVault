//
//  ProfileServiceProtocol.swift
//  RecipeVault
//
//  Created by Wesley Goey on 31/05/26.
//


import Foundation

// MARK: - ProfileService Protocol
protocol ProfileServiceProtocol {
    // MARK: - Get User Profile
    func getUserProfile(userId: String) async throws -> [String: Any]?
    
    // MARK: - Save User Profile
    func saveUserProfile(userId: String, name: String, email: String, currentImageURL: String, newImageData: Data?) async throws -> String
}

//
//  ProfileServiceProtocol.swift
//  RecipeVault
//
//  Created by Wesley Goey on 31/05/26.
//


import Foundation

protocol ProfileServiceProtocol {
    // READ
    func getUserProfile(userId: String) async throws -> [String: Any]?
    
    // UPDATE
    // Mengembalikan String (URL gambar terbaru) agar UI bisa langsung diperbarui
    func saveUserProfile(userId: String, name: String, email: String, currentImageURL: String, newImageData: Data?) async throws -> String
}

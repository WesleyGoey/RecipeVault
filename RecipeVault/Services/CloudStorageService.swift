//
//  CloudStorageService.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 28/05/26.
//


import Foundation
import FirebaseStorage

class CloudStorageService {
    static let shared = CloudStorageService()
    let storage = Storage.storage().reference()
    
    // Validate size (NFR-03)
    func validateSize(image: Data, maxMB: Int = 5) -> Bool {
        let sizeInMB = Double(image.count) / (1024.0 * 1024.0)
        return sizeInMB <= Double(maxMB)
    }
    
    // Upload image and return the download URL
    func uploadImage(image: Data, path: String) async throws -> String {
        guard validateSize(image: image) else {
            throw NSError(domain: "Image too large. Max 5MB allowed.", code: 400, userInfo: nil)
        }
        
        let fileRef = storage.child("\(path)/\(UUID().uuidString).jpg")
        
        _ = try await fileRef.putDataAsync(image, metadata: nil)
        let downloadURL = try await fileRef.downloadURL()
        
        return downloadURL.absoluteString
    }
}
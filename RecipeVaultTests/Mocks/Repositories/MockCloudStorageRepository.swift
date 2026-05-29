//
//  MockCloudStorageRepository.swift
//  RecipeVault
//
//  Created by Wesley Goey on 29/05/26.
//


// MARK: - MockCloudStorageRepository
import Foundation
@testable import RecipeVault

class MockCloudStorageRepository: CloudStorageRepositoryProtocol {
    
    // MARK: - Test Control Properties
    var mockedImageURL = "https://mockstorage.com/image.jpg"
    var shouldThrowError = false
    
    // MARK: - Method Call Trackers
    var isUploadImageCalled = false
    var uploadedPath: String?
    
    // MARK: - Protocol Methods
    func uploadImage(image: Data, path: String) async throws -> String {
        isUploadImageCalled = true
        uploadedPath = path
        
        if shouldThrowError {
            throw NSError(domain: "FirebaseStorageError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Upload failed."])
        }
        
        return mockedImageURL
    }
}

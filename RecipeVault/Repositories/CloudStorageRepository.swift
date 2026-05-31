//
//  CloudStorageRepository.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


// MARK: - CloudStorageRepository
//import Foundation
//import FirebaseStorage
//
//class CloudStorageRepository: CloudStorageRepositoryProtocol {
//    
//    // MARK: - Properties
//    static let shared = CloudStorageRepository()
//    private let storage = Storage.storage().reference()
//    
//    // MARK: - Initializer
//    private init() {}
//    
//    // MARK: - Methods
//    func uploadImage(image: Data, path: String) async throws -> String {
//        let fileName = UUID().uuidString
//        let fileRef = storage.child("\(path)/\(fileName).jpg")
//        
//        _ = try await fileRef.putDataAsync(image, metadata: nil)
//        let downloadURL = try await fileRef.downloadURL()
//        
//        return downloadURL.absoluteString
//    }
//}
import Foundation
import FirebaseStorage

class CloudStorageRepository: CloudStorageRepositoryProtocol {
    static let shared = CloudStorageRepository()
    private let storage = Storage.storage().reference()
    
    private init() {}
    
    func uploadImage(image: Data, path: String) async throws -> String {
        let filename = UUID().uuidString + ".jpg"
        let ref = storage.child(path).child(filename)
        
        // 🚀 Proses upload ke Firebase Storage
        let _ = try await ref.putDataAsync(image, metadata: nil)
        
        // 🚀 Mengambil URL publik setelah sukses upload
        let url = try await ref.downloadURL()
        return url.absoluteString
    }
}

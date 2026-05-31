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
        
        // 🚀 1. Tambahkan Metadata agar Firebase tahu ini adalah file gambar (JPEG)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // 🚀 2. Gunakan Continuation untuk menghindari bug race-condition pada putDataAsync bawaan SDK
        return try await withCheckedThrowingContinuation { continuation in
            
            // Menggunakan putData konvensional (closure) yang lebih dijamin keakuratannya
            ref.putData(image, metadata: metadata) { returnedMetadata, error in
                
                // Jika proses upload gagal (misal karena jaringan atau rules), lemparkan error
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                // Jika upload dipastikan SUKSES, baru kita minta URL Download-nya
                ref.downloadURL { url, downloadError in
                    if let downloadError = downloadError {
                        continuation.resume(throwing: downloadError)
                        return
                    }
                    
                    guard let downloadURL = url?.absoluteString else {
                        continuation.resume(throwing: URLError(.badURL))
                        return
                    }
                    
                    // Kembalikan URL string ke Service Layer
                    continuation.resume(returning: downloadURL)
                }
            }
        }
    }
}

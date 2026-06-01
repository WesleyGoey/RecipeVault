//
//  OtherProfileViewModel.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 01/06/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class OtherProfileViewModel: ObservableObject {
    @Published var creatorName: String = ""
    @Published var profilePictureURL: String = "" // Menyimpan Base64 atau URL
    
    @Published var publicCollections: [RecipeCollection] = []
    @Published var collectionCounts: [String: Int] = [:]
    
    @Published var isLoading: Bool = true
    @Published var operationError: String = "" // 🚀 REVISI: Konsisten untuk Alert UI jika error
    
    let creatorId: String
    
    // 🚀 BERSIH TOTAL: Manfaatkan Koki (Service) yang sudah ada tanpa menyentuh Firestore langsung
    private let profileService = ProfileService.shared
    private let collectionService = CollectionService.shared
    
    init(creatorId: String) {
        self.creatorId = creatorId
    }
    
    func loadCreatorData() async {
        isLoading = true
        operationError = ""
        
        do {
            // 1. Ambil Profil Pencipta lewat ProfileService (Hasil otomatis rapi)
            if let profileData = try await profileService.getUserProfile(userId: creatorId) {
                self.creatorName = profileData["name"] as? String ?? "Unknown Creator"
                self.profilePictureURL = profileData["profilePicture"] as? String ?? ""
            }
            
            // 2. Ambil SEMUA Koleksi milik dia lewat CollectionService (Otomatis ter-decode berkat Codable di Repo)
            let allCollections = try await collectionService.getUserCollections(userId: creatorId)
            
            // 3. Filter secara instan hanya yang Public menggunakan properti bawaan model
            let filteredPublic = allCollections.filter { $0.visibility == .publicVisibility }
            
            // 4. Hitung jumlah resep per koleksi public menggunakan tabel relasi via Service
            var tempCounts: [String: Int] = [:]
            for collection in filteredPublic {
                if let colId = collection.id {
                    let count = (try? await collectionService.getRecipeCountInCollection(collectionId: colId)) ?? 0
                    tempCounts[colId] = count
                }
            }
            
            // 5. Update State serentak agar UI me-render dengan tenang dan akurat
            self.publicCollections = filteredPublic
            self.collectionCounts = tempCounts
            
        } catch {
            // Jika internet putus, tangkap errornya untuk dilempar ke Alert UI
            self.operationError = error.localizedDescription
        }
        
        isLoading = false
    }
}

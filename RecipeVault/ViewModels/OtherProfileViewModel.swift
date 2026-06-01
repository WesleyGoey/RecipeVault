//
//  OtherProfileViewModel.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 01/06/26.
//

import Foundation
import SwiftUI
import Combine // Wajib agar tidak error ObservableObject
import FirebaseFirestore

@MainActor
class OtherProfileViewModel: ObservableObject {
    @Published var creatorName: String = ""
    @Published var profilePictureURL: String = ""
    
    @Published var publicCollections: [RecipeCollection] = []
    @Published var collectionCounts: [String: Int] = [:]
    
    @Published var isLoading: Bool = true
    
    let creatorId: String
    private let db = Firestore.firestore()
    
    init(creatorId: String) {
        self.creatorId = creatorId
    }
    
    func loadCreatorData() async {
        isLoading = true
        await fetchCreatorProfile()
        await fetchPublicCollections()
        isLoading = false
    }
    
    private func fetchCreatorProfile() async {
        do {
            let doc = try await db.collection("users").document(creatorId).getDocument()
            if let data = doc.data() {
                self.creatorName = data["name"] as? String ?? "Unknown Creator"
                self.profilePictureURL = data["profilePictureURL"] as? String ?? ""
            }
        } catch {
            print("Error fetching creator profile: \(error)")
            self.creatorName = "Unknown Creator"
        }
    }
    
    private func fetchPublicCollections() async {
        do {
            // 🚀 1. Hanya ambil koleksi milik user ini untuk menghindari error Firebase Index
            let snapshot = try await db.collection("collections")
                .whereField("userId", isEqualTo: creatorId)
                .getDocuments()
            
            var fetchedCollections: [RecipeCollection] = []
            
            for doc in snapshot.documents {
                let data = doc.data()
                
                // 🚀 2. Ambil nilai "visibility" (Bukan "isPublic")
                let visibilityString = data["visibility"] as? String ?? ""
                
                // 🚀 3. Filter secara manual: Hanya masukkan jika mengandung kata "public"
                if visibilityString.lowercased().contains("public") {
                    
                    // 🚀 4. Format inisialisasi disesuaikan dengan Struct RecipeCollection milikmu
                    var collection = RecipeCollection(
                        userId: creatorId,
                        name: data["name"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        collectionImage: data["collectionImage"] as? String ?? "",
                        visibility: .publicVisibility // Paksa jadi public
                    )
                    collection.id = doc.documentID // ID Dokumen Firestore
                    
                    let recipes = data["recipeIds"] as? [String] ?? []
                    self.collectionCounts[doc.documentID] = recipes.count
                    
                    fetchedCollections.append(collection)
                }
            }
            
            self.publicCollections = fetchedCollections
        } catch {
            print("Error fetching public collections: \(error)")
        }
    }
}

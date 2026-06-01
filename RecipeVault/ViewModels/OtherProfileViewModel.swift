//
//  OtherProfileViewModel.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 01/06/26.
//

import Foundation
import SwiftUI
import Combine
import FirebaseFirestore

@MainActor
class OtherProfileViewModel: ObservableObject {
    @Published var creatorName: String = ""
    @Published var profilePictureURL: String = "" // Menyimpan Base64
    
    @Published var publicCollections: [RecipeCollection] = []
    @Published var collectionCounts: [String: Int] = [:]
    
    @Published var isLoading: Bool = true
    
    let creatorId: String
    private let db = Firestore.firestore()
    private let collectionService = CollectionService.shared // 🚀 Gunakan service untuk count
    
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
                // 🚀 PERBAIKAN: Gunakan key "profilePicture", bukan "profilePictureURL"
                self.profilePictureURL = data["profilePicture"] as? String ?? ""
            }
        } catch {
            print("Error fetching creator profile: \(error)")
            self.creatorName = "Unknown Creator"
        }
    }
    
    private func fetchPublicCollections() async {
        do {
            let snapshot = try await db.collection("collections")
                .whereField("userId", isEqualTo: creatorId)
                .getDocuments()
            
            var fetchedCollections: [RecipeCollection] = []
            
            for doc in snapshot.documents {
                let data = doc.data()
                let visibilityString = data["visibility"] as? String ?? ""
                
                if visibilityString.lowercased().contains("public") {
                    var collection = RecipeCollection(
                        userId: creatorId,
                        name: data["name"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        collectionImage: data["collectionImage"] as? String ?? "",
                        visibility: .publicVisibility
                    )
                    collection.id = doc.documentID
                    
                    // 🚀 PERBAIKAN: Gunakan Junction Table melalui CollectionService
                    let count = (try? await collectionService.getRecipeCountInCollection(collectionId: doc.documentID)) ?? 0
                    self.collectionCounts[doc.documentID] = count
                    
                    fetchedCollections.append(collection)
                }
            }
            
            self.publicCollections = fetchedCollections
        } catch {
            print("Error fetching public collections: \(error)")
        }
    }
}

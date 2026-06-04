//
//  OtherProfileViewModel.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 01/06/26.
//


import Foundation
import SwiftUI
import Combine

// MARK: - OtherProfileViewModel Class
@MainActor
class OtherProfileViewModel: ObservableObject {
    private let profileService = ProfileService.shared
    private let collectionService = CollectionService.shared
    let creatorId: String
    
    @Published var creatorName: String = ""
    @Published var profilePictureURL: String = ""
    @Published var publicCollections: [RecipeCollection] = []
    @Published var collectionCounts: [String: Int] = [:]
    
    @Published var isLoading: Bool = true
    @Published var operationError: String = ""
    
    // MARK: - Initializer
    init(creatorId: String) {
        self.creatorId = creatorId
    }
    
    // MARK: - Load Creator Data
    func loadCreatorData() async {
        isLoading = true
        operationError = ""
        
        do {
            if let profileData = try await profileService.getUserProfile(userId: creatorId) {
                self.creatorName = profileData["name"] as? String ?? "Unknown Creator"
                self.profilePictureURL = profileData["profilePicture"] as? String ?? ""
            }
            
            let allCollections = try await collectionService.getUserCollections(userId: creatorId)
            let filteredPublic = allCollections.filter { $0.visibility == .publicVisibility }
            
            var tempCounts: [String: Int] = [:]
            for collection in filteredPublic {
                if let colId = collection.id {
                    let count = (try? await collectionService.getRecipeCountInCollection(collectionId: colId)) ?? 0
                    tempCounts[colId] = count
                }
            }
            
            self.publicCollections = filteredPublic
            self.collectionCounts = tempCounts
            
        } catch {
            self.operationError = error.localizedDescription
        }
        
        isLoading = false
    }
}

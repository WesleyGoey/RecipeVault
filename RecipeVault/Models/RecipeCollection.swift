//
//  RecipeCollection.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//

import Foundation
import FirebaseFirestore

// MARK: - RecipeCollection Model
struct RecipeCollection: Codable, Identifiable, Equatable {
    @DocumentID var id: String?
    var userId: String
    var name: String
    var description: String
    var collectionImage: String
    var visibility: Visibility
    @ServerTimestamp var createdAt: Date?
    
    // MARK: - Check Ownership
    func isOwnedBy(currentUserId: String) -> Bool {
        return userId == currentUserId
    }
    
    // MARK: - Check Visibility
    func isPublic() -> Bool {
        return visibility == .publicVisibility
    }
}

//
//  Collection.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//

import Foundation
import FirebaseFirestore

// M-05: Collection
struct RecipeCollection: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var name: String
    var description: String
    var collectionImage: String
    var visibility: Visibility
    @ServerTimestamp var createdAt: Date?
    
    // Helper methods from your class diagram
    func isOwnedBy(currentUserId: String) -> Bool {
        return userId == currentUserId
    }
    
    func isPublic() -> Bool {
        return visibility == .publicVisibility
    }
}

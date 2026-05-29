//
// AuthMode.swift
// RecipeVault
//

import Foundation

// Shared enum used by AuthView / ProfileView etc.
// Keep at top-level so both views reference same type.
enum AuthMode {
    case login
    case register
}

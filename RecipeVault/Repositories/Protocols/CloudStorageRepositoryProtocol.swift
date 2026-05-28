//
//  CloudStorageRepositoryProtocol.swift
//  RecipeVault
//
//  Created by Wesley Goey on 28/05/26.
//


// MARK: - CloudStorageRepositoryProtocol
import Foundation

protocol CloudStorageRepositoryProtocol {
    func uploadImage(image: Data, path: String) async throws -> String
}
//
//  MockTheMealDBRepository.swift
//  RecipeVault
//
//  Created by Wesley Goey on 29/05/26.
//


// MARK: - MockTheMealDBRepository
import Foundation
@testable import RecipeVault

class MockTheMealDBRepository: TheMealDBRepositoryProtocol {
    
    // MARK: - Test Control Properties
    var mockedMeals: [MealDBRecipe] = []
    var shouldThrowError = false
    
    // MARK: - Method Call Trackers
    var isSearchMealsCalled = false
    var capturedQuery: String = ""
    
    // MARK: - Protocol Methods
    func searchMeals(query: String) async throws -> [MealDBRecipe] {
        isSearchMealsCalled = true
        capturedQuery = query
        
        if shouldThrowError {
            throw URLError(.badServerResponse)
        }
        
        return mockedMeals
    }
}

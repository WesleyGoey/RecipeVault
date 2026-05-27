//
//  ContentView.swift
//  RecipeVault
//
//  Created by Wesley Goey on 13/05/26.
//

import SwiftUI
import FirebaseFirestore

struct ContentView: View {
    @State private var statusMessage = "Press the button to build your database schema."
    @State private var isBuilding = false
    
    var body: some View {
        ZStack {
            // App Background Color
            Color(hex: "f8fae5").edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Image(systemName: "server.rack")
                    .font(.system(size: 80))
                    .foregroundColor(Color(hex: "43766c")) // Primary Teal
                
                Text("Recipe Vault Setup")
                    .font(.custom("Merriweather-Bold", size: 32, relativeTo: .largeTitle))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.primary)
                
                Text(statusMessage)
                    .font(.custom("Merriweather-Regular", size: 18, relativeTo: .body))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 40)
                
                Button(action: {
                    buildDatabase()
                }) {
                    Text(isBuilding ? "Building..." : "Build Database Schema")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 250)
                        .background(Color(hex: "cd4b12")) // Secondary Orange
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                .disabled(isBuilding)
            }
        }
    }
    
    func buildDatabase() {
        isBuilding = true
        statusMessage = "Pushing data to Firestore..."
        
        // Run the generation script
        instantlyBuildDatabaseSchema()
        
        // Add a slight delay so the UI updates smoothly
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            statusMessage = "✅ Schema successfully generated!\n\nYou can now check your Firebase Console."
            isBuilding = false
        }
    }
    
    func instantlyBuildDatabaseSchema() {
        let db = Firestore.firestore()
        let dummyUserId = "mockUser123" // Simulating a logged-in user
        
        // 1. Auto-create Users Collection & Document
        db.collection("users").document(dummyUserId).setData([
            "name": "Chef Master",
            "email": "chef@example.com",
            "profilePicture": ""
        ])
        
        // 2. Auto-create Favorites Subcollection
        let favoriteRef = db.collection("users").document(dummyUserId).collection("favorites").document()
        favoriteRef.setData([
            "favoriteId": favoriteRef.documentID,
            "recipeId": "52772", // Dummy MealDB ID
            "userId": dummyUserId,
            "recipeSource": "MealDB",
            "savedAt": FieldValue.serverTimestamp()
        ])
        
        // 3. Auto-create Recipes Collection
        let recipeRef = db.collection("recipes").document()
        recipeRef.setData([
            "userId": dummyUserId,
            "title": "My Secret Cookies",
            "description": "Best cookies ever.",
            "ingredients": ["Flour", "Sugar"],
            "steps": ["Mix", "Bake"],
            "category": "Dessert",
            "recipeImage": "",
            "createdAt": FieldValue.serverTimestamp()
        ])
        
        // 4. Auto-create Collections Collection
        let collectionRef = db.collection("collections").document()
        collectionRef.setData([
            "userId": dummyUserId,
            "name": "Weekend Treats",
            "description": "Sweet stuff",
            "collectionImage": "",
            "visibility": "PUBLIC",
            "createdAt": FieldValue.serverTimestamp()
        ])
        
        // 5. Auto-create the Junction Table
        let junctionRef = db.collection("collection_recipes").document()
        junctionRef.setData([
            "collectionId": collectionRef.documentID,
            "recipeId": recipeRef.documentID,
            "addedAt": FieldValue.serverTimestamp()
        ])
    }
}

// Helper extension to use your brand's Hex Colors easily
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue:  Double(b) / 255, opacity: Double(a) / 255)
    }
}

#Preview {
    ContentView()
}

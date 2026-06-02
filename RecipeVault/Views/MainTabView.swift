//
//  MainTabView.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 01/06/26.
//


import SwiftUI

// MARK: - Main Tab View
struct MainTabView: View {
    @State private var selectedTab = 0
    
    @StateObject private var recipeVM = RecipeViewModel()
    
    let mutedTeal = Color(hex: "43766c")
    
    // MARK: - Initializer
    init() {
        let appearance = UITabBarAppearance()
        
        appearance.configureWithOpaqueBackground()
        
        appearance.backgroundColor = UIColor(red: 248/255, green: 250/255, blue: 229/255, alpha: 1.0)
        
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            SearchView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(1)
            
            MyRecipesView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("My Recipes")
                }
                .tag(2)
            
            CollectionsView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "books.vertical.fill")
                    Text("Collections")
                }
                .tag(3)
            
            ProfileView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(4)
        }
        .accentColor(mutedTeal)
        .environmentObject(recipeVM)
    }
}

// MARK: - Preview
#Preview {
    MainTabView()
}

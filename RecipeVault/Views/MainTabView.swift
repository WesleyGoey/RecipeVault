//
//  ContentView.swift
//  RecipeVault
//
//  Created by Wesley Goey on 13/05/26.
//

import SwiftUI

struct MainTabView: View {
    // We pass this in from ContentView so the Profile tab can eventually trigger a logout
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // Track which tab is currently active
    @State private var selectedTab: Tab = .home
    
    // Theme Colors
    let mutedTeal = Color(hex: "43766c")
    let bgYellow = Color(hex: "f8fae5")
    
    // Enum to make switching tabs clean and safe
    enum Tab {
        case home, search, myRecipes, collections, profile
    }
    
    var body: some View {
        // 1. The Main Content Area
        TabView(selection: $selectedTab) {
            
            // MARK: - 1. Home Tab
            VStack {
                Text("Home View")
                    .font(.custom("Merriweather-Bold", size: 28))
                Text("Put your Discovery Feed here.")
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(bgYellow.ignoresSafeArea())
            .tag(Tab.home)
            
            // MARK: - 2. Search Tab
            VStack {
                SearchView()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(bgYellow.ignoresSafeArea())
            .tag(Tab.search)
            
            // MARK: - 3. My Recipes Tab
            VStack {
                Text("My Recipes")
                    .font(.custom("Merriweather-Bold", size: 28))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(bgYellow.ignoresSafeArea())
            .tag(Tab.myRecipes)
            
            // MARK: - 4. Collections Tab
            VStack {
                Text("Collections")
                    .font(.custom("Merriweather-Bold", size: 28))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(bgYellow.ignoresSafeArea())
            .tag(Tab.collections)
            
            // MARK: - 5. Profile Tab
            VStack(spacing: 20) {
                Text("Profile")
                    .font(.custom("Merriweather-Bold", size: 28))
                
                Button(action: {
                    authViewModel.logout()
                }) {
                    Text("Log Out")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 200)
                        .background(Color(hex: "cd4b12")) // burntOrange
                        .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(bgYellow.ignoresSafeArea())
            .tag(Tab.profile)
        }
        .toolbar(.hidden, for: .tabBar)
        .safeAreaInset(edge: .bottom) {
            customTabBar
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

// MARK: - Custom Tab Bar Subview
extension MainTabView {
    private var customTabBar: some View {
        HStack(spacing: 0) {
            TabBarButton(icon: "house", title: "Home", tab: .home, selectedTab: $selectedTab)
            Spacer()
            TabBarButton(icon: "magnifyingglass", title: "Search", tab: .search, selectedTab: $selectedTab)
            Spacer()
            TabBarButton(icon: "book", title: "My Recipes", tab: .myRecipes, selectedTab: $selectedTab)
            Spacer()
            TabBarButton(icon: "books.vertical", title: "Collections", tab: .collections, selectedTab: $selectedTab)
            Spacer()
            TabBarButton(icon: "person", title: "Profile", tab: .profile, selectedTab: $selectedTab)
        }
        .padding(.horizontal, 24)
        .padding(.top, 15)
        .background(
            Color(hex: "f8fae5")
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: -5)
                .ignoresSafeArea(edges: .bottom) // 👈 ADD THIS MAGIC LINE HERE
        )
    }
}

// MARK: - Tab Bar Button Component
struct TabBarButton: View {
    var icon: String
    var title: String
    var tab: MainTabView.Tab
    @Binding var selectedTab: MainTabView.Tab
    
    let mutedTeal = Color(hex: "43766c")
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        }) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    // Makes the active icon solid and inactive icon outlined (if supported)
                    .environment(\.symbolVariants, selectedTab == tab ? .fill : .none)
                    // Makes the active icon slightly bolder
                    .fontWeight(selectedTab == tab ? .bold : .regular)
                
                Text(title)
                    .font(.custom("Merriweather-Regular", size: 10))
            }
            // Colors: Muted Teal if active, gray if inactive
            .foregroundColor(selectedTab == tab ? mutedTeal : Color.gray.opacity(0.8))
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Preview
#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}


import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    // 🚀 Injecting the Global State for tabs that need it
    @StateObject private var recipeVM = RecipeViewModel()
    
    let mutedTeal = Color(hex: "43766c")
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // TAB 1: HOME
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            // TAB 2: SEARCH
            SearchView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(1)
            
            // TAB 3: MY RECIPES
            MyRecipesView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("My Recipes")
                }
                .tag(2)
            
            // TAB 4: COLLECTIONS
            CollectionsView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "books.vertical.fill")
                    Text("Collections")
                }
                .tag(3)
            
            // TAB 5: PROFILE
            ProfileView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(4)
        }
        .accentColor(mutedTeal) // Sets the active tab color
        .environmentObject(recipeVM) // Inject global brain into all tabs
    }
}

#Preview {
    MainTabView()
}

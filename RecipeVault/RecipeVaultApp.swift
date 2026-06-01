//
//  RecipeVaultApp.swift
//  RecipeVault
//
//  Created by Wesley Goey on 13/05/26.
//

import SwiftUI
import FirebaseCore
import FirebaseAppCheck

// MARK: - AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    // MARK: - Application Delegate Methods
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        
        FirebaseApp.configure()
        return true
    }
}

// MARK: - RecipeVaultApp
@main
struct RecipeVaultApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var recipeVM = RecipeViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(authVM)
                .environmentObject(recipeVM)
        }
    }
}

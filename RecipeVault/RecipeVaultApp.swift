//
//  RecipeVaultApp.swift
//  RecipeVault
//
//  Created by Wesley Goey on 13/05/26.
//

import SwiftUI
import FirebaseCore
import FirebaseAppCheck // 🚀 1. WAJIB IMPORT INI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        #if DEBUG
        // 🚀 2. Tukar provider menjadi DEBUG khusus saat dijalankan di Simulator/Xcode Development
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        #endif
        
        FirebaseApp.configure()
        return true
    }
}

@main
struct RecipeVaultApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authVM = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(authVM)
        }
    }
}

//
// ProfileView.swift
// RecipeVault
//

import SwiftUI

// shared AuthMode (ensure you do not have another nested AuthMode)


struct ProfileView: View {
    @StateObject private var vm = ProfileViewModel()
    @State private var selectedTab: Int = 0 // 0 = Collections, 1 = Favorites (used only when logged in)
    @State private var showAuthView: Bool = false
    @State private var authInitialMode: AuthMode = .login

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "FBF9EC").ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        // Header (common)
                        headerSection
                            .padding(.horizontal)

                        // If not logged in: show single auth area (no segments, no lists)
                        if vm.userId.isEmpty {
                            unauthenticatedSingleArea
                                .padding(.horizontal)
                                .padding(.top, 6)
                        } else {
                            // logged-in UI: segmented control + lists
                            segmentedControl
                                .padding(.horizontal)

                            if selectedTab == 0 {
                                collectionsSection
                                    .padding(.horizontal)
                                    .padding(.top, 6)
                            } else {
                                favoritesSection
                                    .padding(.horizontal)
                                    .padding(.top, 6)
                            }
                        }

                        Spacer(minLength: 24)
                    }
                    .padding(.top, 18)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAuthView) {
                // Present auth screen with initial mode requested
                AuthView(vm: vm, initialMode: authInitialMode)
            }
          
            .task { await vm.initializeUserProfile() }
            .onChange(of: selectedTab) { new in
                if new == 1 { Task { await vm.loadFavorites() } } else { Task { await vm.loadCollections() } }
            }
            .alert("Error", isPresented: Binding(get: { !vm.operationError.isEmpty }, set: { if !$0 { vm.operationError = "" } })) {
                Button("OK", role: .cancel) { vm.operationError = "" }
            } message: { Text(vm.operationError) }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        Group {
            if vm.userId.isEmpty {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [Color(hex: "2F6B5E"), Color(hex: "163A2B")], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 96, height: 96)
                            .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 4)
                        Image(systemName: "fork.knife")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                    }

                    VStack(spacing: 6) {
                        Text("Welcome To RecipeVault")
                            .font(.merriweather(22, weightBold: true))
                            .foregroundColor(Color(hex: "163A2B"))
                        Text("Please login or Register")
                            .font(.merriweather(14))
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            } else {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "2F6B5E"))
                            .frame(width: 86, height: 86)
                        if let ui = vm.selectedUIImage {
                            Image(uiImage: ui)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 86, height: 86)
                                .clipShape(Circle())
                        } else if let url = URL(string: vm.profilePictureURL), !vm.profilePictureURL.isEmpty {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image): image.resizable().scaledToFill()
                                default: Color.clear
                                }
                            }
                            .frame(width: 86, height: 86).clipShape(Circle())
                        } else {
                            Text(vm.name.split(separator: " ").prefix(2).compactMap { $0.first }.map { String($0) }.joined())
                                .font(.merriweather(32, weightBold: true))
                                .foregroundColor(.white)
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(vm.name.isEmpty ? "No Name" : vm.name)
                            .font(.merriweather(20, weightBold: true))
                        Text(vm.email)
                            .font(.merriweather(13))
                            .foregroundColor(.gray)
                        HStack(spacing: 10) {
                            Button(action: {
                                do {
                                    try AuthService.shared.logout()
                                    Task { await vm.initializeUserProfile() }
                                } catch {
                                    vm.operationError = "Logout gagal: \(error.localizedDescription)"
                                }
                            }) {
                                Text("Log out")
                                    .font(.merriweather(14))
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    Spacer()
                }
            }
        }
    }

    // MARK: - Unauthenticated single area (simplified)
    private var unauthenticatedSingleArea: some View {
        VStack(spacing: 20) {
            Text("In order to view and create collections, you need to log in or register first.")
                .font(.merriweather(14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            // Two primary choices centered: Login and Register
            HStack(spacing: 12) {
                Button(action: {
                    authInitialMode = .login
                    showAuthView = true
                }) {
                    Text("Login")
                        .font(.merriweather(16, weightBold: true))
                        .frame(minWidth: 120, maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .foregroundColor(Color(hex: "2F6B5E"))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "EDEFE3"), lineWidth: 1))
                }

                Button(action: {
                    authInitialMode = .register
                    showAuthView = true
                }) {
                    Text("Register")
                        .font(.merriweather(16, weightBold: true))
                        .frame(minWidth: 120, maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(hex: "2F6B5E"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .frame(maxWidth: 420) // keep buttons tidy on wider screens
        }
        .padding(.top, 18)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Segmented control (for signed-in)
    private var segmentedControl: some View {
        HStack(spacing: 0) {
            Button(action: { withAnimation { selectedTab = 0 } }) {
                Text("Public Collections")
                    .font(.merriweather(15, weightBold: selectedTab == 0))
                    .foregroundColor(selectedTab == 0 ? .white : Color(hex: "163A2B"))
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(selectedTab == 0 ? Color(hex: "2F6B5E") : Color.white)
                    .cornerRadius(12)
                    .shadow(color: selectedTab == 0 ? Color.black.opacity(0.06) : Color.clear, radius: 6, x: 0, y: 3)
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: { withAnimation { selectedTab = 1 } }) {
                Text("Favorites")
                    .font(.merriweather(15, weightBold: selectedTab == 1))
                    .foregroundColor(selectedTab == 1 ? .white : Color(hex: "163A2B"))
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(selectedTab == 1 ? Color(hex: "2F6B5E") : Color.white)
                    .cornerRadius(12)
                    .shadow(color: selectedTab == 1 ? Color.black.opacity(0.06) : Color.clear, radius: 6, x: 0, y: 3)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(4)
        .background(Color.white.opacity(0.9))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
    }

    // MARK: - Collections when signed-in
    private var collectionsSection: some View {
        Group {
            if vm.isLoading {
                ProgressView().padding()
            } else if vm.collections.isEmpty {
                VStack(spacing: 12) {
                    Text("Anda belum punya koleksi")
                        .font(.merriweather(18, weightBold: true))
                        .foregroundColor(Color(hex: "163A2B"))
                    Text("Buat koleksi untuk menyimpan resep favorit Anda.")
                        .font(.merriweather(14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 36)
                    Button(action: { vm.showingCreateSheet = true }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Collection")
                                .font(.merriweather(15, weightBold: true))
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(Color(hex: "E4572E"))
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 4)
                    }
                }
                .padding(.top, 12)
            } else {
                LazyVGrid(columns: columns, spacing: 18) {
                    ForEach(vm.collections) { col in
                        CollectionCardView(collection: col, recipeCount: vm.collectionCounts[col.id ?? ""] ?? 0)
                            .frame(height: 170)
                    }
                }
            }
        }
    }

    // MARK: - Favorites when signed-in
    private var favoritesSection: some View {
        Group {
            if vm.isLoading {
                ProgressView().padding()
            } else if vm.favoriteRecipes.isEmpty {
                VStack(spacing: 12) {
                    Text("Belum ada favorit")
                        .font(.merriweather(18, weightBold: true))
                        .foregroundColor(Color(hex: "163A2B"))
                    Text("Simpan resep ke favorit untuk menemukannya lebih cepat.")
                        .font(.merriweather(14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 36)
                }
                .padding(.top, 12)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(vm.favoriteRecipes) { recipe in
                        RecipeCardView(recipe: recipe)
                            .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
        }
    }
}

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
#endif

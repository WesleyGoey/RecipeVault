//
//  ProfileView.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 30/05/26.
//

import SwiftUI

// MARK: - Profile View
struct ProfileView: View {
    @Binding var selectedTab: Int
    @State private var navResetID = UUID()

    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var recipeVM: RecipeViewModel
    @StateObject private var vm = ProfileViewModel()

    @State private var selectedSegment: Int = 0

    @State private var showAuthView: Bool = false
    @State private var authInitialMode: AuthMode = .login

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    let burntOrange = Color(hex: "cd4b12")
    let mutedTeal = Color(hex: "43766c")
    let bgYellow = Color(hex: "FBF9EC")

    var body: some View {
        NavigationStack {
            ZStack {
                bgYellow.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        headerSection
                            .padding(.horizontal)

                        if !authVM.isLoggedIn {
                            unauthenticatedSingleArea
                                .padding(.horizontal)
                                .padding(.top, 6)
                        } else {
                            segmentedControl
                                .padding(.horizontal)

                            if selectedSegment == 0 {
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
                AuthView(vm: vm, initialMode: authInitialMode)
                    .environmentObject(authVM)
            }
            .sheet(isPresented: $vm.showingEditProfile) {
                EditProfileView(vm: vm)
            }
            .task { await vm.initializeUserProfile() }
            .onChange(of: selectedSegment) { new in
                if new == 1 {
                    Task { await vm.loadFavoriteRecipes() }
                } else {
                    Task { await vm.loadPublicCollections() }
                }
            }
            .onChange(of: authVM.isLoggedIn) { loggedIn in
                if loggedIn { Task { await vm.initializeUserProfile() } }
            }
            .alert(
                "Error",
                isPresented: Binding(
                    get: { !vm.operationError.isEmpty },
                    set: { if !$0 { vm.operationError = "" } }
                )
            ) {
                Button("OK", role: .cancel) { vm.operationError = "" }
            } message: {
                Text(vm.operationError)
            }
            .onReceive(
                NotificationCenter.default.publisher(for: .favoritesUpdated)
            ) { _ in
                if selectedSegment == 1 {
                    Task { await vm.loadFavoriteRecipes() }
                }
            }
        }
        .id(navResetID)
        .onChange(of: selectedTab) { newTab in
            if newTab != 4 {
                navResetID = UUID()
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        Group {
            if !authVM.isLoggedIn {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "2F6B5E"),
                                        Color(hex: "163A2B"),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 96, height: 96)
                            .shadow(
                                color: Color.black.opacity(0.12),
                                radius: 6,
                                x: 0,
                                y: 4
                            )
                        Image(systemName: "fork.knife")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                    }

                    VStack(spacing: 6) {
                        Text("Welcome To RecipeVault")
                            .font(.merriweather(22, weight: .bold))
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
                                .resizable().scaledToFill().frame(
                                    width: 86,
                                    height: 86
                                ).clipShape(Circle())
                        }
                        else if !vm.profilePictureURL.isEmpty {
                            if vm.profilePictureURL.hasPrefix("http") {
                                AsyncImage(url: URL(string: vm.profilePictureURL)) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable().scaledToFill()
                                    default: Color.clear
                                    }
                                }
                                .frame(width: 86, height: 86).clipShape(Circle())
                            } else if let data = Data(base64Encoded: vm.profilePictureURL), let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable().scaledToFill()
                                    .frame(width: 86, height: 86).clipShape(Circle())
                            } else {
                                Text(
                                    vm.name.split(separator: " ").prefix(2)
                                        .compactMap { $0.first }.map { String($0) }
                                        .joined()
                                )
                                .font(.merriweather(32, weight: .bold))
                                .foregroundColor(.white)
                            }
                        } else {
                            Text(
                                vm.name.split(separator: " ").prefix(2)
                                    .compactMap { $0.first }.map { String($0) }
                                    .joined()
                            )
                            .font(.merriweather(32, weight: .bold))
                            .foregroundColor(.white)
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(vm.name.isEmpty ? "No Name" : vm.name)
                            .font(.merriweather(20, weight: .bold))
                        Text(vm.email)
                            .font(.merriweather(13))
                            .foregroundColor(.gray)

                        HStack(spacing: 10) {
                            Button(action: { vm.showingEditProfile = true }) {
                                Text("Edit Profile")
                                    .font(.merriweather(12, weight: .bold))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(mutedTeal)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }

                            Button(action: {
                                authVM.logout()
                            }) {
                                Text("Log out")
                                    .font(.merriweather(12, weight: .bold))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color.white)
                                    .foregroundColor(burntOrange)
                                    .overlay(
                                        Capsule().stroke(
                                            burntOrange,
                                            lineWidth: 1.5
                                        )
                                    )
                            }
                        }
                        .padding(.top, 4)
                    }
                    Spacer()
                }
            }
        }
    }

    // MARK: - Unauthenticated single area
    private var unauthenticatedSingleArea: some View {
        VStack(spacing: 20) {
            Text(
                "In order to view and create collections, you need to log in or register first."
            )
            .font(.merriweather(14))
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)

            HStack(spacing: 12) {
                Button(action: {
                    authInitialMode = .login
                    showAuthView = true
                }) {
                    Text("Login")
                        .font(.merriweather(16, weight: .bold))
                        .frame(minWidth: 120, maxWidth: .infinity).padding(
                            .vertical,
                            12
                        )
                        .background(Color.white).foregroundColor(
                            Color(hex: "2F6B5E")
                        )
                        .cornerRadius(12).overlay(
                            RoundedRectangle(cornerRadius: 12).stroke(
                                Color(hex: "EDEFE3"),
                                lineWidth: 1
                            )
                        )
                }

                Button(action: {
                    authInitialMode = .register
                    showAuthView = true
                }) {
                    Text("Register")
                        .font(.merriweather(16, weight: .bold))
                        .frame(minWidth: 120, maxWidth: .infinity).padding(
                            .vertical,
                            12
                        )
                        .background(Color(hex: "2F6B5E")).foregroundColor(
                            .white
                        ).cornerRadius(12)
                }
            }
            .frame(maxWidth: 420)
        }
        .padding(.top, 18).frame(maxWidth: .infinity)
    }

    // MARK: - Segmented control
    private var segmentedControl: some View {
        HStack(spacing: 0) {
            Button(action: { withAnimation { selectedSegment = 0 } }) {
                Text("Public Collections")
                    .font(
                        .merriweather(
                            15,
                            weight: selectedSegment == 0 ? .bold : .regular
                        )
                    )
                    .foregroundColor(
                        selectedSegment == 0 ? .white : Color(hex: "163A2B")
                    )
                    .padding(.vertical, 10).frame(maxWidth: .infinity)
                    .background(
                        selectedSegment == 0
                            ? Color(hex: "2F6B5E") : Color.clear
                    )
                    .cornerRadius(12)
                    .shadow(
                        color: selectedSegment == 0
                            ? Color.black.opacity(0.06) : Color.clear,
                        radius: 6,
                        x: 0,
                        y: 3
                    )
            }.buttonStyle(PlainButtonStyle())

            Button(action: { withAnimation { selectedSegment = 1 } }) {
                Text("Favorites")
                    .font(
                        .merriweather(
                            15,
                            weight: selectedSegment == 1 ? .bold : .regular
                        )
                    )
                    .foregroundColor(
                        selectedSegment == 1 ? .white : Color(hex: "163A2B")
                    )
                    .padding(.vertical, 10).frame(maxWidth: .infinity)
                    .background(
                        selectedSegment == 1
                            ? Color(hex: "2F6B5E") : Color.clear
                    )
                    .cornerRadius(12)
                    .shadow(
                        color: selectedSegment == 1
                            ? Color.black.opacity(0.06) : Color.clear,
                        radius: 6,
                        x: 0,
                        y: 3
                    )
            }.buttonStyle(PlainButtonStyle())
        }
        .padding(4).background(Color.white.opacity(0.9)).cornerRadius(14)
        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
    }

    // MARK: - Collections Section
    private var collectionsSection: some View {
        Group {
            if vm.isLoading {
                ProgressView().padding()
            } else if vm.publicCollections.isEmpty {
                VStack(spacing: 12) {
                    Text("No public collections")
                        .font(.merriweather(18, weight: .bold)).foregroundColor(
                            Color(hex: "163A2B")
                        )
                    Text(
                        "Collections that you set as 'Public' will appear here."
                    )
                    .font(.merriweather(14)).foregroundColor(.gray)
                    .multilineTextAlignment(.center).padding(.horizontal, 36)
                }.padding(.top, 12)
            } else {
                LazyVGrid(columns: columns, spacing: 18) {
                    ForEach(vm.publicCollections) { col in
                        NavigationLink(
                            destination: CollectionDetailView(
                                collection: col,
                                viewModel: CollectionViewModel()
                            )
                        ) {
                            ProfileCollectionCardView(
                                collection: col,
                                recipeCount: vm.collectionCounts[col.id ?? ""]
                                    ?? 0
                            )
                            .frame(height: 170)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }

    // MARK: - Favorites Section
    private var favoritesSection: some View {
        Group {
            if vm.isLoading {
                ProgressView().padding()
            } else if vm.favoriteRecipes.isEmpty {
                VStack(spacing: 12) {
                    Text("Belum ada favorit")
                        .font(.merriweather(18, weight: .bold)).foregroundColor(
                            Color(hex: "163A2B")
                        )
                    Text(
                        "Simpan resep ke favorit untuk menemukannya lebih cepat."
                    )
                    .font(.merriweather(14)).foregroundColor(.gray)
                    .multilineTextAlignment(.center).padding(.horizontal, 36)
                }.padding(.top, 12)
            } else {
                LazyVGrid(columns: columns, spacing: 18) {
                    ForEach(vm.favoriteRecipes) { recipe in
                        NavigationLink(
                            destination: RecipeDetailView(
                                recipe: recipe,
                                viewModel: recipeVM
                            )
                        ) {
                            ProfileFavoriteCardView(
                                recipe: recipe,
                                recipeVM: recipeVM,
                                profileVM: vm
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ProfileView(selectedTab: .constant(4))
        .environmentObject(AuthViewModel())
}

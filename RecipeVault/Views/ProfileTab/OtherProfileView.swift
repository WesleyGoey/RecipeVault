//
//  OtherProfileView.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 01/06/26.
//


import SwiftUI

struct OtherProfileView: View {
    @StateObject private var vm: OtherProfileViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Injeksi CollectionViewModel global (opsional, jika NavigationLink ke detail membutuhkannya)
    @StateObject private var collectionVM = CollectionViewModel()
    
    let bgYellow = Color(hex: "f8fae5")
    let mutedTeal = Color(hex: "43766c")
    let darkText = Color.primary
    
    private let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
    
    init(creatorId: String) {
        // Menginisialisasi ViewModel dengan ID kreator yang di-passing
        _vm = StateObject(wrappedValue: OtherProfileViewModel(creatorId: creatorId))
    }
    
    var body: some View {
        ZStack {
            bgYellow.ignoresSafeArea()
            
            if vm.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // MARK: - Header Profil Kreator
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "2F6B5E"))
                                    .frame(width: 96, height: 96)
                                
                                if let url = URL(string: vm.profilePictureURL), !vm.profilePictureURL.isEmpty {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .success(let image): image.resizable().scaledToFill()
                                        default: Color.clear
                                        }
                                    }
                                    .frame(width: 96, height: 96)
                                    .clipShape(Circle())
                                } else {
                                    Text(vm.creatorName.split(separator: " ").prefix(2).compactMap { $0.first }.map { String($0) }.joined().uppercased())
                                        .font(.merriweather(32, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 4)
                            
                            VStack(spacing: 4) {
                                Text(vm.creatorName)
                                    .font(.merriweather(24, weight: .bold))
                                    .foregroundColor(darkText)
                                
                                Text("Public Creator")
                                    .font(.merriweather(14))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.top, 24)
                        
                        Divider()
                            .padding(.horizontal, 24)
                        
                        // MARK: - Daftar Public Collections
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Public Collections")
                                .font(.merriweather(20, weight: .bold))
                                .foregroundColor(darkText)
                                .padding(.horizontal, 24)
                            
                            if vm.publicCollections.isEmpty {
                                VStack(spacing: 8) {
                                    Image(systemName: "books.vertical")
                                        .font(.system(size: 40))
                                        .foregroundColor(mutedTeal.opacity(0.4))
                                    Text("\(vm.creatorName) hasn't published any collections yet.")
                                        .font(.merriweather(14))
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 32)
                            } else {
                                LazyVGrid(columns: columns, spacing: 18) {
                                    ForEach(vm.publicCollections) { col in
                                        // 🚀 Menggunakan kartu dari ProfileView
                                        NavigationLink(destination: CollectionDetailView(collection: col, viewModel: collectionVM)) {
                                            ProfileCollectionCardView(collection: col, recipeCount: vm.collectionCounts[col.id ?? ""] ?? 0)
                                                .frame(height: 170)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await vm.loadCreatorData()
        }
    }
}

#Preview {
    OtherProfileView(creatorId: "dummy_id")
}
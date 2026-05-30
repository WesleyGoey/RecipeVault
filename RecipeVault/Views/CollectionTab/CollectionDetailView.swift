//
//  CollectionDetailView.swift
//  RecipeVault
//
//  Created by Wesley Goey on 29/05/26.
//

import SwiftUI

struct CollectionDetailView: View {
    @State private var collection: RecipeCollection
    @ObservedObject var viewModel: CollectionViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    let bgYellow = Color(hex: "f8fae5")
    let mutedTeal = Color(hex: "43766c")
    let burntOrange = Color(hex: "cd4b12")
    let darkText = Color.primary
    
    init(collection: RecipeCollection, viewModel: CollectionViewModel) {
        self._collection = State(initialValue: collection)
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                heroImageSection
                
                VStack(alignment: .leading, spacing: 20) {
                    authorSection
                    
                    Text(collection.description)
                        .font(.merriweather(15))
                        .foregroundColor(.gray)
                        .lineSpacing(4)
                        .padding(.top, -8)
                    
                    Text("Recipes (\(viewModel.recipesInCollection.count))")
                        .font(.merriweather(20, weight: .bold))
                        .padding(.top, 10)
                    
                    recipesListSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(bgYellow.ignoresSafeArea())
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        
        // MENDENGARKAN PERUBAHAN DATA UNTUK REAL-TIME UPDATE DI HALAMAN DETAIL
        .onChange(of: viewModel.myCollections) { updatedCollections in
            if let latest = updatedCollections.first(where: { $0.id == collection.id }) {
                withAnimation { self.collection = latest }
            }
        }
        
        .task {
            guard let id = collection.id else { return }
            await viewModel.loadRecipesForCollection(collectionId: id)
        }
        .sheet(isPresented: $showingEditSheet) {
            CollectionEditView(collectionToEdit: collection, viewModel: viewModel)
        }
        .alert("Delete Collection", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteCollection(collection: collection)
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to delete this collection?")
        }
    }
}

// MARK: - Subviews
extension CollectionDetailView {
    
    // MARK: - Hero Image Section (Diperbarui dengan Placeholder Folder)
    private var heroImageSection: some View {
        ZStack(alignment: .top) {
            
            if collection.collectionImage.isEmpty {
                // 🚀 Placeholder jika URL gambar Koleksi kosong
                ZStack {
                    mutedTeal.opacity(0.15)
                    Image(systemName: "square.stack.fill")
                        .font(.system(size: 60))
                        .foregroundColor(mutedTeal.opacity(0.5))
                }
                .frame(height: 320).frame(maxWidth: .infinity).clipped()
            } else {
                AsyncImage(url: URL(string: collection.collectionImage)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle().fill(Color.gray.opacity(0.3)).overlay(ProgressView())
                    case .success(let image):
                        Color.clear.overlay(image.resizable().scaledToFill()).clipped()
                    case .failure:
                        // 🚀 Placeholder jika URL error
                        ZStack {
                            mutedTeal.opacity(0.15)
                            Image(systemName: "square.stack.fill")
                                .font(.system(size: 60))
                                .foregroundColor(mutedTeal.opacity(0.5))
                        }
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 320).frame(maxWidth: .infinity).clipped()
            }
            
            // Gradient overlay
            LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.7)]), startPoint: .center, endPoint: .bottom)
                .frame(height: 320)
            
            // Nav Bar Area
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left").font(.system(size: 16, weight: .bold)).foregroundColor(.white).frame(width: 44, height: 44).background(Color.black.opacity(0.4)).clipShape(Circle())
                }
                Spacer()
                if viewModel.isOwner(collection: collection) {
                    Menu {
                        Button { showingEditSheet = true } label: { Label("Edit Collection", systemImage: "pencil") }
                        Button(role: .destructive) { showingDeleteAlert = true } label: { Label("Delete Collection", systemImage: "trash") }
                    } label: {
                        Image(systemName: "ellipsis").font(.system(size: 18, weight: .bold)).foregroundColor(.white).frame(width: 44, height: 44).background(Color.black.opacity(0.4)).clipShape(Circle())
                    }
                }
            }
            .padding(.top, 50).padding(.horizontal, 20)
            
            // Text Details on Image
            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                HStack {
                    Image(systemName: collection.visibility == .publicVisibility ? "globe" : "lock.fill")
                    Text(collection.visibility.rawValue.uppercased())
                }
                .font(.system(size: 10, weight: .bold)).foregroundColor(.white).padding(.horizontal, 12).padding(.vertical, 6).background(mutedTeal.opacity(0.8)).clipShape(Capsule())
                
                Text(collection.name).font(.merriweather(32, weight: .bold)).foregroundColor(.white)
                Text("\(viewModel.recipesInCollection.count) recipes").font(.merriweather(14)).foregroundColor(.white.opacity(0.8))
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 320) // Memastikan text ada di bawah gambar
        }
    }
    
    private var authorSection: some View {
        HStack(spacing: 12) {
            Circle().fill(mutedTeal).frame(width: 46, height: 46).overlay(Text("ME").font(.merriweather(14, weight: .bold)).foregroundColor(.white))
            VStack(alignment: .leading, spacing: 2) {
                Text("You").font(.merriweather(16, weight: .bold))
                Text("Your collection").font(.merriweather(14)).foregroundColor(.gray)
            }
            Spacer()
        }.padding(.vertical, 10)
    }
    
    // MARK: - Daftar Resep di Dalam Koleksi (Diperbarui dengan Placeholder Garpu Pisau)
    private var recipesListSection: some View {
        LazyVStack(spacing: 16) {
            ForEach(viewModel.recipesInCollection, id: \.title) { recipe in
                HStack(spacing: 16) {
                    Group {
                        if recipe.recipeImage.isEmpty {
                            // 🚀 Placeholder jika Resep ini tak punya gambar
                            ZStack {
                                mutedTeal.opacity(0.15)
                                Image(systemName: "fork.knife").foregroundColor(mutedTeal.opacity(0.5))
                            }
                        } else {
                            AsyncImage(url: URL(string: recipe.recipeImage)) { phase in
                                switch phase {
                                case .empty:
                                    Color.gray.opacity(0.2).overlay(ProgressView())
                                case .success(let image):
                                    image.resizable().scaledToFill()
                                case .failure:
                                    // 🚀 Placeholder jika gambar Resep error ditarik
                                    ZStack {
                                        mutedTeal.opacity(0.15)
                                        Image(systemName: "fork.knife").foregroundColor(mutedTeal.opacity(0.5))
                                    }
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(recipe.title).font(.merriweather(16, weight: .bold)).foregroundColor(darkText).lineLimit(1)
                        HStack(spacing: 8) {
                            Text(recipe.category).font(.system(size: 10, weight: .bold)).foregroundColor(.white).padding(.horizontal, 10).padding(.vertical, 4).background(burntOrange).clipShape(Capsule())
                            HStack(spacing: 4) { Image(systemName: "clock"); Text("30 min") }.font(.caption).foregroundColor(.gray)
                        }
                    }
                    Spacer()
                    Image(systemName: "chevron.right").foregroundColor(.gray.opacity(0.5))
                }
                .padding(12)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
            }
        }
    }
}

#Preview {
    CollectionDetailView(
        collection: RecipeCollection(
            userId: "123",
            name: "Weeknight Favorites",
            description: "Quick dinners",
            collectionImage: "", // Kosong untuk mengetes Icon
            visibility: .publicVisibility
        ),
        viewModel: CollectionViewModel()
    )
}

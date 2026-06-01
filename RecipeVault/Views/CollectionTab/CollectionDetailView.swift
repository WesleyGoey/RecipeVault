//
//  CollectionDetailView.swift
//  RecipeVault
//
//  Created by Nicholas Gerwin Mawardji on 29/05/26.
//

import FirebaseFirestore
import SwiftUI

struct CollectionDetailView: View {
    let collection: RecipeCollection
    @ObservedObject var viewModel: CollectionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false

    // State untuk menampung nama pembuat koleksi (Real Data)
    @State private var creatorName: String = "Loading..."
    
    // Injeksi RecipeViewModel untuk fitur 3-Dot Menu
    @StateObject private var recipeVM = RecipeViewModel()

    // Theme Colors
    let bgYellow = Color(hex: "f8fae5")
    let mutedTeal = Color(hex: "43766c")
    let burntOrange = Color(hex: "cd4b12")
    let darkText = Color.primary

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                heroImageSection

                VStack(alignment: .leading, spacing: 20) {
                    authorSection

                    Text(collection.description.isEmpty ? "Tidak ada deskripsi." : collection.description)
                        .font(.merriweather(15, weight: .regular))
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
        
        // BOTTOM SHEET UNTUK MENYIMPAN RESEP (Dari 3-Dot Menu)
        .sheet(isPresented: $recipeVM.showCollectionSheet) {
            CollectionSelectionSheet(viewModel: recipeVM)
        }
        
        .task {
            guard let id = collection.id else { return }
            await viewModel.loadRecipesForCollection(collectionId: id)
            await recipeVM.loadFavoriteIds() // Muat status favorit

            if viewModel.isOwner(collection: collection) {
                creatorName = "You"
            } else {
                do {
                    let db = Firestore.firestore()
                    let doc = try await db.collection("users").document(collection.userId).getDocument()
                    if let name = doc.data()?["name"] as? String {
                        creatorName = name
                    } else {
                        creatorName = "Unknown Chef"
                    }
                } catch {
                    creatorName = "Unknown Chef"
                }
            }
        }
        
        // 🚀 MEMANGGIL COLLECTION EDIT VIEW YANG SEBENARNYA
        .sheet(isPresented: $showingEditSheet) {
            CollectionEditView(collectionToEdit: collection, viewModel: viewModel)
        }
        
        .alert("Delete Collection", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
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

    private var heroImageSection: some View {
        ZStack(alignment: .top) {
            Color.clear
                .frame(height: 320)
                .overlay(
                    Group {
                        if let imageData = Data(base64Encoded: collection.collectionImage),
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage).resizable().scaledToFill()
                        }
                        else {
                            let defaultUrl = "https://images.unsplash.com/photo-1495195134817-a165d4292816?q=80&w=800&auto=format&fit=crop"
                            let validUrl = collection.collectionImage.starts(with: "http") ? collection.collectionImage : defaultUrl
                            
                            AsyncImage(url: URL(string: validUrl.trimmingCharacters(in: .whitespacesAndNewlines))) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Rectangle().fill(Color.gray.opacity(0.3)).overlay(ProgressView())
                            }
                        }
                    }
                )
                .clipped()
                .overlay(
                    LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.7)]), startPoint: .center, endPoint: .bottom)
                )

            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.black.opacity(0.4))
                        .clipShape(Circle())
                }
                Spacer()
                
                // 🚀 3-DOT MENU UNTUK EDIT/DELETE KOLEKSI
                if viewModel.isOwner(collection: collection) {
                    Menu {
                        Button {
                            showingEditSheet = true
                        } label: { Label("Edit Collection", systemImage: "pencil") }
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: { Label("Delete Collection", systemImage: "trash") }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.top, 50)
            .padding(.horizontal, 20)

            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                HStack {
                    Image(systemName: collection.visibility == .publicVisibility ? "globe" : "lock.fill")
                    Text(collection.visibility.rawValue.uppercased())
                }
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(mutedTeal.opacity(0.8))
                .clipShape(Capsule())

                Text(collection.name)
                    .font(.merriweather(32, weight: .bold))
                    .foregroundColor(.white)

                Text("\(viewModel.recipesInCollection.count) recipes")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var authorSection: some View {
        NavigationLink(destination: OtherProfileView(creatorId: collection.userId)) {
            HStack(spacing: 12) {
                Circle()
                    .fill(mutedTeal)
                    .frame(width: 46, height: 46)
                    .overlay(
                        Text(String(creatorName.prefix(2)).uppercased())
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(creatorName)
                        .font(.merriweather(16, weight: .bold))
                        .foregroundColor(darkText)
                    Text(viewModel.isOwner(collection: collection) ? "Your collection" : "Public Creator")
                        .font(.merriweather(14, weight: .regular))
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.gray)
            }
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.001))
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var recipesListSection: some View {
        LazyVStack(spacing: 16) {
            ForEach(viewModel.recipesInCollection, id: \.id) { recipe in
                CollectionRecipeRow(recipe: recipe, parentCollection: collection, collectionVM: viewModel)
                    .environmentObject(recipeVM)
            }
        }
    }
}

// MARK: - STRUCT TERPISAH
struct CollectionRecipeRow: View {
    let recipe: Recipe
    let parentCollection: RecipeCollection
    
    // Injeksi ViewModels
    @EnvironmentObject var recipeVM: RecipeViewModel
    @ObservedObject var collectionVM: CollectionViewModel
    
    // Theme Colors
    let burntOrange = Color(hex: "cd4b12")
    let darkText = Color.primary
    let mutedTeal = Color(hex: "43766c")
    
    var body: some View {
        NavigationLink(destination: RecipeDetailView(recipe: recipe, viewModel: recipeVM)) {
            HStack(spacing: 16) {
                
                Group {
                    if recipe.recipeImage.isEmpty {
                        placeholderImage
                    }
                    else if recipe.recipeImage.starts(with: "http") {
                        AsyncImage(url: URL(string: recipe.recipeImage.trimmingCharacters(in: .whitespacesAndNewlines))) { phase in
                            if let image = phase.image {
                                image.resizable().scaledToFill()
                            } else if phase.error != nil {
                                placeholderImage
                            } else {
                                ZStack {
                                    mutedTeal.opacity(0.15)
                                    ProgressView()
                                }
                            }
                        }
                    }
                    else if let imageData = Data(base64Encoded: recipe.recipeImage),
                            let uiImg = UIImage(data: imageData) {
                        Image(uiImage: uiImg).resizable().scaledToFill()
                    }
                    else {
                        placeholderImage
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(recipe.title)
                        .font(.merriweather(16, weight: .bold))
                        .foregroundColor(darkText)
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 8) {
                        Text(recipe.category)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10).padding(.vertical, 4)
                            .background(burntOrange).clipShape(Capsule())
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                            Text("30 min")
                        }
                        .font(.caption)
                        .foregroundColor(.gray)
                    }
                }
                Spacer()
                
                Menu {
                    Button {
                        Task { await recipeVM.openCollectionSheet(for: recipe) }
                    } label: {
                        Label("Add to Collection", systemImage: "folder.badge.plus")
                    }
                    
                    let isFav = recipeVM.isFavorite(recipe: recipe)
                    Button {
                        Task { await recipeVM.toggleFavorite(recipe: recipe) }
                    } label: {
                        Label(isFav ? "Remove Favorite" : "Add to Favorite", systemImage: isFav ? "heart.slash" : "heart")
                    }
                    
                    if collectionVM.isOwner(collection: parentCollection) {
                        Divider()
                        Button(role: .destructive) {
                            Task { await collectionVM.removeRecipeFromCollection(recipe: recipe, from: parentCollection) }
                        } label: {
                            Label("Remove from Folder", systemImage: "trash")
                        }
                    }
                    
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.gray)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Tampilan placeholder untuk resep tanpa gambar
    private var placeholderImage: some View {
        ZStack {
            mutedTeal.opacity(0.15)
            Image(systemName: "fork.knife")
                .font(.system(size: 30))
                .foregroundColor(mutedTeal.opacity(0.5))
        }
    }
}

#Preview {
    CollectionDetailView(
        collection: RecipeCollection.mockCollections[0],
        viewModel: CollectionViewModel()
    )
    .environmentObject(RecipeViewModel())
}

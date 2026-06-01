//
//  CollectionDetailView.swift
//  RecipeVault
//
//  Created by Nicholas Gerwin Mawardji on 29/05/26.
//

import FirebaseFirestore  // Diperlukan untuk fetch User
import SwiftUI

struct CollectionDetailView: View {
    let collection: RecipeCollection
    @ObservedObject var viewModel: CollectionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false

    // 🚀 State untuk menampung nama pembuat koleksi (Real Data)
    @State private var creatorName: String = "Loading..."

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

                    Text(collection.description)
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
        .task {
            guard let id = collection.id else { return }
            await viewModel.loadRecipesForCollection(collectionId: id)

            if viewModel.isOwner(collection: collection) {
                creatorName = "You"
            } else {
                do {
                    let db = Firestore.firestore()
                    let doc = try await db.collection("users").document(
                        collection.userId
                    ).getDocument()
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
        .sheet(isPresented: $showingEditSheet) {
            Text("Edit Sheet for \(collection.name)")
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
                        let validUrl =
                            collection.collectionImage.isEmpty
                            ? "https://images.unsplash.com/photo-1495195134817-a165d4292816?q=80&w=800&auto=format&fit=crop"
                            : collection.collectionImage

                        AsyncImage(
                            url: URL(
                                string: validUrl.trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                )
                            )
                        ) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Rectangle().fill(Color.gray.opacity(0.3)).overlay(
                                ProgressView()
                            )
                        }
                    }
                )
                .clipped()
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear, .black.opacity(0.7),
                        ]),
                        startPoint: .center,
                        endPoint: .bottom
                    )
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
                if viewModel.isOwner(collection: collection) {
                    Menu {
                        Button {
                            showingEditSheet = true
                        } label: {
                            Label("Edit Collection", systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete Collection", systemImage: "trash")
                        }
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
                    Image(
                        systemName: collection.visibility == .publicVisibility
                            ? "globe" : "lock.fill"
                    )
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

    // 🚀 BISA DI-KLIK & MENGARAH KE OTHERPROFILEVIEW
    private var authorSection: some View {
        NavigationLink(
            destination: OtherProfileView(creatorId: collection.userId)
        ) {
            HStack(spacing: 12) {
                Circle()
                    .fill(mutedTeal)
                    .frame(width: 46, height: 46)
                    .overlay(
                        // Menggunakan 2 huruf pertama dari nama asli kreator
                        Text(String(creatorName.prefix(2)).uppercased())
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(creatorName)
                        .font(.merriweather(16, weight: .bold))
                        .foregroundColor(darkText)

                    Text(
                        viewModel.isOwner(collection: collection)
                            ? "Your collection" : "Public Creator"
                    )
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

    // 🚀 List memanggil Struct Terpisah agar Xcode tidak lambat
    private var recipesListSection: some View {
        LazyVStack(spacing: 16) {
            ForEach(viewModel.recipesInCollection, id: \.id) { recipe in
                CollectionRecipeRow(recipe: recipe)
            }
        }
    }
}

// MARK: - 🚀 STRUCT TERPISAH (Meringankan beban kompilasi Xcode)
struct CollectionRecipeRow: View {
    let recipe: Recipe
    
    // 🚀 PERBAIKAN 1: Panggil Global State di sini
    @EnvironmentObject var recipeVM: RecipeViewModel
    
    // Theme Colors
    let burntOrange = Color(hex: "cd4b12")
    let darkText = Color.primary
    
    var body: some View {
        // 🚀 PERBAIKAN 2: Gunakan 'recipeVM', JANGAN 'RecipeViewModel()'
        NavigationLink(destination: RecipeDetailView(recipe: recipe, viewModel: recipeVM)) {
            HStack(spacing: 16) {
                
                // Fallback Gambar Tanpa PercentEncoding yang merusak URL
                let rawUrl = recipe.recipeImage.isEmpty ? "https://images.unsplash.com/photo-1495195134817-a165d4292816?q=80&w=800&auto=format&fit=crop" : recipe.recipeImage
                
                AsyncImage(url: URL(string: rawUrl.trimmingCharacters(in: .whitespacesAndNewlines))) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else if phase.error != nil {
                        Color.gray.opacity(0.3).overlay(Image(systemName: "photo").foregroundColor(.gray))
                    } else {
                        Color.gray.opacity(0.2).overlay(ProgressView())
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
                Image(systemName: "chevron.right").foregroundColor(.gray.opacity(0.5))
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CollectionDetailView(
        collection: RecipeCollection.mockCollections[0],
        viewModel: CollectionViewModel()
    )
    .environmentObject(RecipeViewModel()) // Jangan lupa pasang ini agar preview tidak crash
}

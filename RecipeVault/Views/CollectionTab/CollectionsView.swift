//
//  CollectionsView.swift
//  RecipeVault
//
//  Created by NicholasaGerwin Mawardjiwin Mawardji on 29/05/26.
//


import SwiftUI

struct CollectionsView: View {
    @StateObject private var viewModel = CollectionViewModel()
    
    @State private var showingCreateSheet = false
    @State private var collectionToEdit: RecipeCollection? = nil
    @State private var collectionToDelete: RecipeCollection? = nil
    @State private var showingDeleteAlert = false
    
    let bgYellow = Color(hex: "f8fae5")
    let mutedTeal = Color(hex: "43766c")
    let darkText = Color.primary
    
    let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                bgYellow.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        headerSection
                        gridSection
                    }
                }
                floatingActionButton
            }
            .navigationBarHidden(true)
            .task {
                if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                    viewModel.myCollections = RecipeCollection.mockCollections
                } else {
                    await viewModel.loadMyCollections()
                }
            }
            // 🚀 INJEKSI VIEWMODEL KE SHEET
            .sheet(isPresented: $showingCreateSheet) {
                CollectionCreateView(viewModel: viewModel)
            }
            .sheet(item: $collectionToEdit) { collection in
                CollectionEditView(collectionToEdit: collection, viewModel: viewModel)
            }
            .alert("Delete Collection", isPresented: $showingDeleteAlert, presenting: collectionToDelete) { collection in
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task { await viewModel.deleteCollection(collection: collection) }
                }
            } message: { collection in
                Text("Are you sure you want to delete '\(collection.name)'? Recipes inside will not be deleted.")
            }
        }
    }
}

extension CollectionsView {
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("My Collections")
                .font(.merriweather(36, weight: .bold)) // 🚀 FONT
                .foregroundColor(darkText)
            
            HStack {
                Button(action: {}) {
                    Label("Alphabetical", systemImage: "arrow.up.arrow.down").font(.merriweather(14, weight: .bold)).foregroundColor(darkText)
                }
                Spacer()
                Button(action: {}) { Image(systemName: "square.grid.2x2").font(.system(size: 20)).foregroundColor(darkText) }
            }
        }
        .padding(.horizontal, 20).padding(.top, 24).padding(.bottom, 16)
    }
    
    private var gridSection: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(viewModel.myCollections, id: \.name) { collection in
                NavigationLink(destination: CollectionDetailView(collection: collection, viewModel: viewModel)) {
                    CollectionCardView(collection: collection) // Pastikan file ini ada
                }
                .buttonStyle(PlainButtonStyle())
                .contextMenu {
                    if viewModel.isOwner(collection: collection) {
                        Button { collectionToEdit = collection } label: { Label("Edit Collection", systemImage: "pencil") }
                        Button(role: .destructive) {
                            collectionToDelete = collection
                            showingDeleteAlert = true
                        } label: { Label("Delete Collection", systemImage: "trash") }
                    }
                }
            }
        }.padding(.horizontal, 20).padding(.bottom, 120)
    }
    
    private var floatingActionButton: some View {
        Button(action: { showingCreateSheet = true }) {
            Image(systemName: "plus").font(.system(size: 24, weight: .semibold)).foregroundColor(.white)
                .frame(width: 64, height: 64).background(mutedTeal).clipShape(Circle()).shadow(color: mutedTeal.opacity(0.3), radius: 8, x: 0, y: 4)
        }.padding(.trailing, 20).padding(.bottom, 24)
    }
}

// CollectionCardView is managed in CollectionCardView.swift

#Preview {
    CollectionsView()
}

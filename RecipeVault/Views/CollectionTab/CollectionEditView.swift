//
//  CollectionEditView.swift
//  RecipeVault
//
//  Created by Wesley Goey on 30/05/26.
//


import SwiftUI
import PhotosUI

struct CollectionEditView: View {
    @Environment(\.dismiss) var dismiss
    
    let collectionToEdit: RecipeCollection
    @ObservedObject var viewModel: CollectionViewModel
    
    @State private var name: String
    @State private var description: String
    @State private var visibility: Visibility
    
    @State private var photoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isImageDeleted: Bool = false
    
    let bgYellow = Color(hex: "f8fae5")
    let burntOrange = Color(hex: "cd4b12")
    let mutedTeal = Color(hex: "43766c")
    
    init(collectionToEdit: RecipeCollection, viewModel: CollectionViewModel) {
        self.collectionToEdit = collectionToEdit
        self.viewModel = viewModel
        _name = State(initialValue: collectionToEdit.name)
        _description = State(initialValue: collectionToEdit.description)
        _visibility = State(initialValue: collectionToEdit.visibility)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    photoUploadSection
                    inputSection(title: "COLLECTION NAME", placeholder: "e.g. Weeknight Favourites", text: $name)
                    descriptionSection
                    visibilitySection
                    Spacer().frame(height: 100)
                }
                .padding(20)
            }
            .background(bgYellow.ignoresSafeArea())
            .navigationTitle("Edit Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(burntOrange)
                        .font(.merriweather(16, weight: .bold))
                }
            }
            .overlay(alignment: .bottom) {
                updateButton
            }
        }
    }
}

// MARK: - Subviews
extension CollectionEditView {
    private var photoUploadSection: some View {
        ZStack(alignment: .topTrailing) {
            PhotosPicker(selection: $photoItem, matching: .images, photoLibrary: .shared()) {
                if let selectedImage {
                    Image(uiImage: selectedImage).resizable().scaledToFill().frame(height: 160).frame(maxWidth: .infinity).clipShape(RoundedRectangle(cornerRadius: 16))
                } else if !collectionToEdit.collectionImage.isEmpty && !isImageDeleted {
                    AsyncImage(url: URL(string: collectionToEdit.collectionImage)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Rectangle().fill(Color.gray.opacity(0.2)).overlay(ProgressView())
                    }.frame(height: 160).frame(maxWidth: .infinity).clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    placeholderView
                }
            }
            .onChange(of: photoItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                        selectedImage = image
                        isImageDeleted = false
                    }
                }
            }
            
            if selectedImage != nil || (!collectionToEdit.collectionImage.isEmpty && !isImageDeleted) {
                Button(action: {
                    withAnimation {
                        selectedImage = nil
                        photoItem = nil
                        isImageDeleted = true
                    }
                }) {
                    Image(systemName: "trash.circle.fill").resizable().frame(width: 32, height: 32).foregroundColor(.red).background(Circle().fill(Color.white)).shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }.padding(12)
            }
        }
    }
    
    private var placeholderView: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.badge.plus").font(.system(size: 32))
            Text("Change Cover Image").font(.merriweather(16, weight: .bold))
        }
        .foregroundColor(mutedTeal).frame(maxWidth: .infinity).padding(.vertical, 40).background(Color.white).cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(mutedTeal.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [8])))
    }
    
    private func inputSection(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.merriweather(12, weight: .bold)).foregroundColor(.gray)
            TextField(placeholder, text: text).font(.merriweather(14)).padding(16).background(Color.white).cornerRadius(12)
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DESCRIPTION").font(.merriweather(12, weight: .bold)).foregroundColor(.gray)
            ZStack(alignment: .topLeading) {
                if description.isEmpty {
                    Text("What is this collection about?").font(.merriweather(14)).foregroundColor(Color(UIColor.placeholderText)).padding(16)
                }
                TextEditor(text: $description).font(.merriweather(14)).padding(8).scrollContentBackground(.hidden)
            }
            .frame(minHeight: 100).background(Color.white).cornerRadius(12)
        }
    }
    
    private var visibilitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("VISIBILITY").font(.merriweather(12, weight: .bold)).foregroundColor(.gray)
            HStack(spacing: 0) {
                Button(action: { withAnimation { visibility = .publicVisibility } }) {
                    HStack {
                        Image(systemName: "globe")
                        Text("Public").font(.merriweather(16, weight: .bold))
                    }
                    .foregroundColor(visibility == .publicVisibility ? .black : .gray)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(visibility == .publicVisibility ? Color.white : Color.clear)
                    .clipShape(Capsule())
                    .shadow(color: visibility == .publicVisibility ? .black.opacity(0.05) : .clear, radius: 4, x: 0, y: 2)
                }
                
                Button(action: { withAnimation { visibility = .privateVisibility } }) {
                    HStack {
                        Image(systemName: "lock")
                        Text("Private").font(.merriweather(16, weight: .bold))
                    }
                    .foregroundColor(visibility == .privateVisibility ? .black : .gray)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(visibility == .privateVisibility ? Color.white : Color.clear)
                    .clipShape(Capsule())
                    .shadow(color: visibility == .privateVisibility ? .black.opacity(0.05) : .clear, radius: 4, x: 0, y: 2)
                }
            }
            .padding(6).background(Color.black.opacity(0.05)).clipShape(Capsule())
        }
    }
    
    private var updateButton: some View {
        Button(action: {
            Task {
                guard let colId = collectionToEdit.id else { return }
                let imgData = selectedImage?.jpegData(compressionQuality: 0.8)
                let success = await viewModel.updateCollection(collectionId: colId, name: name, description: description, visibility: visibility, oldImageURL: collectionToEdit.collectionImage, newImageData: imgData, isImageDeleted: isImageDeleted)
                if success { dismiss() }
            }
        }) {
            HStack {
                if viewModel.isLoading { ProgressView().tint(.white).padding(.trailing, 8) }
                Text(viewModel.isLoading ? "Updating..." : "Update Collection").font(.merriweather(16, weight: .bold)).foregroundColor(.white)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 16).background(mutedTeal).cornerRadius(16)
        }
        .disabled(name.isEmpty || viewModel.isLoading)
        .padding(.horizontal, 20).padding(.bottom, 10)
        .background(LinearGradient(gradient: Gradient(colors: [bgYellow.opacity(0), bgYellow]), startPoint: .top, endPoint: .bottom))
    }
}

#Preview {
    CollectionEditView(collectionToEdit: RecipeCollection.mockCollections[0], viewModel: CollectionViewModel())
}

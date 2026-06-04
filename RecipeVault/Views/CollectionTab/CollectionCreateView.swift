//
//  CollectionCreateView.swift
//  RecipeVault
//
//  Created by Nicholas Gerwin Mawardji on 29/05/26.
//

import SwiftUI
import PhotosUI

// MARK: - Collection Create View
struct CollectionCreateView: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var viewModel: CollectionViewModel
    
    @State private var name = ""
    @State private var description = ""
    @State private var visibility: Visibility = .publicVisibility
    
    @State private var photoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var rawImageData: Data?
    
    let bgYellow = Color(hex: "f8fae5")
    let burntOrange = Color(hex: "cd4b12")
    let mutedTeal = Color(hex: "43766c")
    
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
            .navigationTitle("New Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(burntOrange)
                        .font(.merriweather(16, weight: .bold))
                }
            }
            .overlay(alignment: .bottom) {
                saveButton
            }
            .alert("Upload Failed", isPresented: Binding(
                get: { !viewModel.operationError.isEmpty },
                set: { if !$0 { viewModel.operationError = "" } }
            )) {
                Button("OK", role: .cancel) { viewModel.operationError = "" }
            } message: {
                Text(viewModel.operationError)
            }
        }
    }
}

// MARK: - Collection Create Subview
extension CollectionCreateView {
    
    // MARK: - Photo Upload Section with PhotosPicker
    private var photoUploadSection: some View {
        PhotosPicker(selection: $photoItem, matching: .images, photoLibrary: .shared()) {
            if let selectedImage {
                Image(uiImage: selectedImage).resizable().scaledToFill().frame(height: 160).frame(maxWidth: .infinity).clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "photo.badge.plus").font(.system(size: 32))
                    Text("Add Cover Image").font(.merriweather(16, weight: .bold))
                }
                .foregroundColor(mutedTeal).frame(maxWidth: .infinity).padding(.vertical, 40).background(Color.white).cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(mutedTeal.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [8])))
            }
        }
        .onChange(of: photoItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                    self.selectedImage = image
                    // 🚀 KOMPRESI MENTAH 100% DI LATAR BELAKANG
                    self.rawImageData = image.jpegData(compressionQuality: 1.0)
                }
            }
        }
    }
     
    // MARK: - Input Section (Name & Description)
    private func inputSection(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.merriweather(12, weight: .bold)).foregroundColor(.gray)
            TextField(placeholder, text: text).font(.merriweather(14)).padding(16).background(Color.white).cornerRadius(12)
        }
    }
    
    // MARK: - Description Section with TextEditor and Placeholder
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
    
    // MARK: - Visibility Section with Custom Toggle Buttons
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
    
    // MARK: - Save Button with Loading State and Disabled State
    private var saveButton: some View {
        Button(action: {
            Task {
                let success = await viewModel.createCollection(
                    name: name,
                    description: description,
                    visibility: visibility,
                    imageData: rawImageData
                )
                if success { dismiss() }
            }
        }) {
            HStack {
                if viewModel.isLoading { ProgressView().tint(.white).padding(.trailing, 8) }
                Text(viewModel.isLoading ? "Saving..." : "Save Collection")
                    .font(.merriweather(16, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 16).background(mutedTeal).cornerRadius(16)
        }
        .disabled(name.isEmpty || viewModel.isLoading)
        .padding(.horizontal, 20).padding(.bottom, 10)
        .background(LinearGradient(gradient: Gradient(colors: [bgYellow.opacity(0), bgYellow]), startPoint: .top, endPoint: .bottom))
    }
}

// MARK: - Preview
#Preview {
    CollectionCreateView(viewModel: CollectionViewModel())
}

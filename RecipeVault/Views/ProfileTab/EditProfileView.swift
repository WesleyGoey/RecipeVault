//
//  EditProfileView.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 01/06/26.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @ObservedObject var vm: ProfileViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var phPickerItem: PhotosPickerItem? = nil
    @State private var showingImagePicker: Bool = false

    var body: some View {
        // 1. AREA KONTEN SEKARANG FULL SCROLLVIEW
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                
                // Avatar & Change Photo Button
                avatarSection
                
                // Input TextFields
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("NAME").font(.caption).foregroundColor(.gray)
                        TextField("Name", text: $vm.name)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                    }
                    
                    // Password Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CHANGE PASSWORD").font(.caption).foregroundColor(.gray)
                            .padding(.bottom, 4)
                        
                        SecureField("Old Password", text: $vm.oldPassword)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                        
                        SecureField("New Password (min 8 char)", text: $vm.newPassword)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                        
                        SecureField("Confirm New Password", text: $vm.confirmNewPassword)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                    }
                }
                
                // 🚀 2. AREA TOMBOL DIPINDAH KE DALAM SCROLLVIEW
                VStack(spacing: 12) {
                    if vm.isLoading {
                        ProgressView()
                    }
                    
                    Button(action: {
                        Task {
                            // Tutup keyboard saat simpan
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            
                            await vm.saveProfileChanges()
                            
                            if !vm.oldPassword.isEmpty || !vm.newPassword.isEmpty || !vm.confirmNewPassword.isEmpty {
                                await vm.changePassword()
                            }
                            
                            if vm.operationError.isEmpty {
                                dismiss()
                            }
                        }
                    }) {
                        Text("Save Changes")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "2F6B5E"))
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                    }
                    .disabled(vm.isLoading)
                }
                .padding(.top, 16) // Memberikan sedikit jarak ekstra antara textfield terakhir dan tombol
                
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color(hex: "FBF9EC").ignoresSafeArea())
        .onTapGesture {
            // Menutup keyboard jika tap area kosong
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .photosPicker(isPresented: $showingImagePicker, selection: $phPickerItem, matching: .images)
        .onChange(of: phPickerItem) { newItem in
            Task {
                if let item = newItem, let data = try? await item.loadTransferable(type: Data.self) {
                    vm.selectedImageData = data
                    vm.selectedUIImage = UIImage(data: data)
                }
            }
        }
        .alert("Error", isPresented: Binding(get: { !vm.operationError.isEmpty }, set: { if !$0 { vm.operationError = "" } })) {
            Button("OK", role: .cancel) { vm.operationError = "" }
        } message: { Text(vm.operationError) }
    }
    
    // Potongan View terpisah agar badan utama bersih
    private var avatarSection: some View {
        ZStack(alignment: .bottom) {
            Circle()
                .fill(Color(hex: "2F6B5E"))
                .frame(width: 120, height: 120)
                .overlay(
                    Group {
                        if let ui = vm.selectedUIImage {
                            Image(uiImage: ui).resizable().scaledToFill()
                        } else if let url = URL(string: vm.profilePictureURL), !vm.profilePictureURL.isEmpty {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image): image.resizable().scaledToFill()
                                default: Color.clear
                                }
                            }
                        } else {
                            Text(initials())
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .clipShape(Circle())
                )
                .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)

            Button(action: { showingImagePicker = true }) {
                Text("CHANGE PHOTO")
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 16)
                    .background(Color(hex: "163A2B").opacity(0.95))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .shadow(radius: 4)
                    .offset(y: 12)
            }
        }
    }

    private func initials() -> String {
        let n = vm.name.isEmpty ? "AR" : vm.name
        let parts = n.split(separator: " ")
        return parts.prefix(2).compactMap { $0.first }.map { String($0) }.joined().uppercased()
    }
}

// MARK: - Preview
#Preview {
    EditProfileView(vm: ProfileViewModel())
}

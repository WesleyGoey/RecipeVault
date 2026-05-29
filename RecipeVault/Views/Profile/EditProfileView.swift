//
// EditProfileView.swift
// RecipeVault
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @ObservedObject var vm: ProfileViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var phPickerItem: PhotosPickerItem? = nil
    @State private var showingImagePicker: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    // Avatar + Change Photo
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
                                .padding(.horizontal, 18)
                                .background(Color(hex: "163A2B").opacity(0.9))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .shadow(radius: 6)
                                .offset(y: 12)
                        }
                    }
                    .padding(.top, 24)

                    // Name field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("NAME").font(.caption).foregroundColor(.gray)
                        TextField("Name", text: $vm.name)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
                    }
                    .padding(.horizontal, 18)

                    // Change password
                    VStack(alignment: .leading, spacing: 12) {
                        Text("CHANGE PASSWORD").font(.caption).foregroundColor(.gray)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("OLD PASSWORD").font(.caption2).foregroundColor(.gray)
                            SecureField("Enter current password", text: $vm.oldPassword)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.03), radius: 6)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("NEW PASSWORD").font(.caption2).foregroundColor(.gray)
                            SecureField("At least 8 characters", text: $vm.newPassword)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.03), radius: 6)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("CONFIRM NEW PASSWORD").font(.caption2).foregroundColor(.gray)
                            SecureField("Re-enter new password", text: $vm.confirmNewPassword)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.03), radius: 6)
                        }
                    }
                    .padding(.horizontal, 18)

                    Spacer().frame(height: 80)
                }
                .padding(.bottom, 24)
            }

            // Bottom Save Button
            VStack {
                if vm.isLoading { ProgressView().padding() }
                Button(action: {
                    Task {
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
                        .cornerRadius(20)
                        .padding(.horizontal, 18)
                        .shadow(radius: 6)
                }
                .disabled(vm.isLoading)
                .padding(.bottom, 12)
            }
            .background(Color(hex: "FBF9EC"))
        }
        .background(Color(hex: "FBF9EC").ignoresSafeArea())
        .photosPicker(isPresented: $showingImagePicker, selection: $phPickerItem, matching: .images)
        .onChange(of: phPickerItem) { newItem in
            Task {
                guard let item = newItem else { return }
                if let data = try? await item.loadTransferable(type: Data.self) {
                    vm.selectedImageData = data
                    vm.selectedUIImage = UIImage(data: data)
                }
            }
        }
        .onAppear { Task { await vm.initializeUserProfile() } }
        .alert("Error", isPresented: Binding(get: { !vm.operationError.isEmpty }, set: { if !$0 { vm.operationError = "" } })) {
            Button("OK", role: .cancel) { vm.operationError = "" }
        } message: { Text(vm.operationError) }
    }

    private func initials() -> String {
        let name = vm.name.isEmpty ? "AR" : vm.name
        let parts = name.split(separator: " ")
        return parts.prefix(2).compactMap { $0.first }.map { String($0) }.joined()
    }
}

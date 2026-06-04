//
//  AuthView.swift
//  RecipeVault
//
//  Created by Sean tandjaja on 30/05/26.
//

import SwiftUI

// MARK: - Login/Register View
struct AuthView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    @ObservedObject var vm: ProfileViewModel
    var initialMode: AuthMode = .login
    @Environment(\.dismiss) private var dismiss

    @State private var mode: AuthMode = .login

    @State private var loginEmail: String = ""
    @State private var loginPassword: String = ""

    @State private var regName: String = ""
    @State private var regEmail: String = ""
    @State private var regPassword: String = ""
    @State private var regConfirmPassword: String = ""
    
    // MARK: - Initializer
    init(vm: ProfileViewModel, initialMode: AuthMode = .login) {
        self.vm = vm
        self.initialMode = initialMode
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "FBF9EC").ignoresSafeArea()

                VStack(spacing: 0) {
                    header
                        .frame(maxWidth: 360)
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            if mode == .login {
                                loginForm
                            } else {
                                registerForm
                            }
                            
                            if !authVM.errorMessage.isEmpty {
                                Text(authVM.errorMessage)
                                    .font(.merriweather(13, weight: .bold))
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: 360)
                            }

                            Button(action: { Task { await submit() } }) {
                                HStack {
                                    if authVM.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.9)
                                            .padding(.trailing, 4)
                                    }
                                    Text(mode == .login ? "Login" : "Create account")
                                        .font(.merriweather(18, weight: .bold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(mode == .login ? Color(hex: "2F6B5E") : Color(hex: "E4572E"))
                                .foregroundColor(.white)
                                .cornerRadius(14)
                                .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 4)
                            }
                            .disabled(authVM.isLoading || !isFormValid())
                            .padding(.top, 10)

                            HStack {
                                Button(action: { dismiss() }) {
                                    Text("Cancel")
                                        .font(.merriweather(14, weight: .regular))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Button(action: {
                                    withAnimation {
                                        mode = mode == .login ? .register : .login
                                        authVM.errorMessage = ""
                                    }
                                }) {
                                    Text(mode == .login ? "Create account" : "Have account? Login")
                                        .font(.merriweather(14, weight: .bold))
                                        .foregroundColor(Color(hex: "2F6B5E"))
                                }
                            }
                            .padding(.top, 16)
                            .padding(.bottom, 40)
                        }
                        .frame(maxWidth: 360)
                        .padding(.horizontal, 20)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .onAppear {
                mode = initialMode
                if !vm.email.trimmingCharacters(in: .whitespaces).isEmpty {
                    loginEmail = vm.email
                    regEmail = vm.email
                }
            }
            .navigationBarHidden(true)
            .disabled(authVM.isLoading)
        }
    }

    // MARK: - Circle Header
    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color(hex: "2F6B5E"), Color(hex: "163A2B")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 72, height: 72)
                    .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 4)
                Image(systemName: "fork.knife")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 34, height: 34)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(mode == .login ? "Welcome back" : "Create your account")
                    .font(.merriweather(20, weight: .bold))
                    .foregroundColor(Color(hex: "163A2B"))
                Text(mode == .login ? "Sign in to access your collections and favorites." : "Register to save favorites and create collections.")
                    .font(.merriweather(13, weight: .regular))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }

    // MARK: - Login form
    private var loginForm: some View {
        VStack(spacing: 14) {
            CustomTextField(title: "Email", placeholder: "email@example.com", text: $loginEmail, keyboard: .emailAddress, isWords: false)
            CustomSecureField(title: "Password", placeholder: "Password", text: $loginPassword)
        }
    }

    //MARK: - Register form
    private var registerForm: some View {
        VStack(spacing: 14) {
            CustomTextField(title: "Name", placeholder: "Full name", text: $regName, keyboard: .default, isWords: true)
            CustomTextField(title: "Email", placeholder: "email@example.com", text: $regEmail, keyboard: .emailAddress, isWords: false)
            CustomSecureField(title: "Password", placeholder: "At least 8 characters", text: $regPassword)
            CustomSecureField(title: "Confirm Password", placeholder: "Confirm password", text: $regConfirmPassword)
        }
    }

    // MARK: - Actions & validation
    private func isFormValid() -> Bool {
        if mode == .login {
            return !loginEmail.trimmingCharacters(in: .whitespaces).isEmpty && !loginPassword.isEmpty
        } else {
            // 🚀 PERBAIKAN: Tombol aktif selama semua field diisi teks, agar validasi pesan error di dalam submit() bisa berjalan saat ditekan.
            return !regName.trimmingCharacters(in: .whitespaces).isEmpty &&
                   !regEmail.trimmingCharacters(in: .whitespaces).isEmpty &&
                   !regPassword.isEmpty &&
                   !regConfirmPassword.isEmpty
        }
    }
    
    // MARK: - Submit login or registration
    private func submit() async {
        authVM.errorMessage = ""

        if mode == .login {
            guard !loginEmail.trimmingCharacters(in: .whitespaces).isEmpty, !loginPassword.isEmpty else {
                authVM.errorMessage = "Email and password needed."
                return
            }
            
            authVM.email = loginEmail.trimmingCharacters(in: .whitespacesAndNewlines)
            authVM.password = loginPassword
            await authVM.login()
            
            if authVM.isLoggedIn {
                await vm.initializeUserProfile()
                dismiss()
            }
            
        } else {
            let nameTrim = regName.trimmingCharacters(in: .whitespacesAndNewlines)
            let emailTrim = regEmail.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // 🚀 PERBAIKAN LOGIKA VALIDASI: Diperiksa berurutan dari atas ke bawah
            guard !nameTrim.isEmpty else { authVM.errorMessage = "Input name."; return }
            guard emailTrim.contains("@") else { authVM.errorMessage = "Invalid email."; return }
            guard regPassword.count >= 8 else { authVM.errorMessage = "Password minimun 8 characters"; return }
            guard regPassword == regConfirmPassword else { authVM.errorMessage = "Password did not match."; return }

            authVM.name = nameTrim
            authVM.email = emailTrim
            authVM.password = regPassword
            await authVM.register()
            
            if authVM.isLoggedIn {
                await vm.initializeUserProfile()
                dismiss()
            }
        }
    }
}

// MARK: - Text Field To Prevent Bug
struct CustomTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var isWords: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.merriweather(12, weight: .bold))
                .foregroundColor(.gray)

            TextField(placeholder, text: $text)
                .keyboardType(keyboard)
                .padding(14)
                .font(.merriweather(16, weight: .regular))
                .textInputAutocapitalization(isWords ? .words : .never)
                .autocorrectionDisabled(true)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Secure Field To Prevent Bug
struct CustomSecureField: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.merriweather(12, weight: .bold))
                .foregroundColor(.gray)

            SecureField(placeholder, text: $text)
                .padding(14)
                .font(.merriweather(16, weight: .regular))
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Preview
#Preview {
    AuthView(vm: ProfileViewModel(), initialMode: .login)
}

//
// AuthView.swift
// RecipeVault
//

import SwiftUI


struct AppTextAutocapitalization {
    // Digunakan hanya sebagai flag sederhana pembantu di dalam field
    var isWords: Bool
}

struct AuthView: View {
    // 🚀 PERBAIKAN 1: Injeksi AuthViewModel sebagai otak utama layar ini
    @StateObject private var authVM = AuthViewModel()
    
    // Tetap menggunakan ProfileViewModel hanya untuk refresh data profil setelah sukses login
    @ObservedObject var vm: ProfileViewModel
    var initialMode: AuthMode = .login
    @Environment(\.dismiss) private var dismiss

    @State private var mode: AuthMode = .login

    // login fields
    @State private var loginEmail: String = ""
    @State private var loginPassword: String = ""

    // register fields
    @State private var regName: String = ""
    @State private var regEmail: String = ""
    @State private var regPassword: String = ""
    @State private var regConfirmPassword: String = ""

    @State private var showSuccessToast: Bool = false
    
    // 🚀 PERBAIKAN 2: Variabel isLoading dan errorMessage dihapus dari @State karena sudah ada di authVM

    init(vm: ProfileViewModel, initialMode: AuthMode = .login) {
        self.vm = vm
        self.initialMode = initialMode
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "FBF9EC").ignoresSafeArea()

                VStack(spacing: 18) {
                    header
                        .frame(maxWidth: 360)
                        .padding(.top, 20)
                        .padding(.horizontal, 20)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            if mode == .login {
                                loginForm
                            } else {
                                registerForm
                            }
                        }
                        .frame(maxWidth: 360)
                        .padding(.top, 6)
                        .padding(.horizontal, 20)
                    }

                    // 🚀 PERBAIKAN 3: Membaca errorMessage dari AuthViewModel
                    if !authVM.errorMessage.isEmpty {
                        Text(authVM.errorMessage)
                            .font(.merriweather(13))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 360)
                            .padding(.horizontal, 20)
                    }

                    // Primary action button
                    Button(action: { Task { await submit() } }) {
                        HStack {
                            // 🚀 PERBAIKAN 4: Membaca isLoading dari AuthViewModel
                            if authVM.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.9)
                            }
                            Text(mode == .login ? "Login" : "Create account")
                                .font(.merriweather(18, weightBold: true))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(mode == .login ? Color(hex: "2F6B5E") : Color(hex: "E4572E"))
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 4)
                    }
                    .disabled(authVM.isLoading || !isFormValid())
                    .frame(maxWidth: 360)
                    .padding(.top, 6)
                    .padding(.horizontal, 20)

                    // Footer: Cancel + toggle
                    HStack {
                        Button(action: { dismiss() }) {
                            Text("Cancel")
                                .font(.merriweather(14))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button(action: { withAnimation { mode = mode == .login ? .register : .login } }) {
                            Text(mode == .login ? "Create account" : "Have account? Login")
                                .font(.merriweather(14, weightBold: true))
                                .foregroundColor(Color(hex: "2F6B5E"))
                        }
                    }
                    .frame(maxWidth: 360)
                    .padding(.bottom, 18)
                    .padding(.horizontal, 20)

                    Spacer(minLength: 6)
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

    // MARK: - Header
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
                    .font(.merriweather(20, weightBold: true))
                    .foregroundColor(Color(hex: "163A2B"))
                Text(mode == .login ? "Sign in to access your collections and favorites." : "Register to save favorites and create collections.")
                    .font(.merriweather(13))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(.horizontal, 0)
    }

    // MARK: - Forms
    private var loginForm: some View {
        VStack(spacing: 14) {
            labeledField(title: "Email", placeholder: "email@example.com", text: $loginEmail, keyboard: .emailAddress, isSecure: false, isWords: false)
            labeledField(title: "Password", placeholder: "Password", text: $loginPassword, keyboard: .default, isSecure: true, isWords: false)
        }
    }

    private var registerForm: some View {
        VStack(spacing: 14) {
            labeledField(title: "Name", placeholder: "Full name", text: $regName, keyboard: .default, isSecure: false, isWords: true)
            labeledField(title: "Email", placeholder: "email@example.com", text: $regEmail, keyboard: .emailAddress, isSecure: false, isWords: false)
            labeledField(title: "Password", placeholder: "At least 8 characters", text: $regPassword, keyboard: .default, isSecure: true, isWords: false)
            labeledField(title: "Confirm", placeholder: "Confirm password", text: $regConfirmPassword, keyboard: .default, isSecure: true, isWords: false)
        }
    }

    // MARK: - Labeled field
    private func labeledField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default,
        isSecure: Bool = false,
        isWords: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.merriweather(12))
                .foregroundColor(.gray)

            Group {
                if isSecure {
                    SecureField(placeholder, text: text)
                        .padding(12)
                        .font(.merriweather(16))
                } else {
                    TextField(placeholder, text: text)
                        .keyboardType(keyboard)
                        .padding(12)
                        .font(.merriweather(16))
                        .autocapitalization(isWords ? .words : .none)
                        .disableAutocorrection(true)
                }
            }
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
        }
    }

    // MARK: - Actions & validation
    private func isFormValid() -> Bool {
        if mode == .login {
            return !loginEmail.trimmingCharacters(in: .whitespaces).isEmpty && !loginPassword.isEmpty
        } else {
            return !regName.trimmingCharacters(in: .whitespaces).isEmpty &&
                   regEmail.contains("@") &&
                   regPassword.count >= 8 &&
                   regPassword == regConfirmPassword
        }
    }

    // 🚀 PERBAIKAN 5: Mendelegasikan Logika Otentikasi ke AuthViewModel
    private func submit() async {
        // Bersihkan error sebelum mencoba lagi
        authVM.errorMessage = ""

        if mode == .login {
            // Validasi lokal
            guard !loginEmail.trimmingCharacters(in: .whitespaces).isEmpty, !loginPassword.isEmpty else {
                authVM.errorMessage = "Email dan password dibutuhkan."
                return
            }
            
            // Masukkan data ke ViewModel dan jalankan Login
            authVM.email = loginEmail.trimmingCharacters(in: .whitespacesAndNewlines)
            authVM.password = loginPassword
            await authVM.login()
            
            // Jika berhasil masuk, refresh data profil dan tutup sheet
            if authVM.isLoggedIn {
                await vm.initializeUserProfile()
                dismiss()
            }
            
        } else {
            // Validasi lokal
            let nameTrim = regName.trimmingCharacters(in: .whitespacesAndNewlines)
            let emailTrim = regEmail.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard !nameTrim.isEmpty else { authVM.errorMessage = "Masukkan username."; return }
            guard emailTrim.contains("@") && !regPassword.isEmpty else { authVM.errorMessage = "Email / password tidak valid."; return }
            guard regPassword == regConfirmPassword else { authVM.errorMessage = "Password dan konfirmasi tidak cocok."; return }
            guard regPassword.count >= 8 else { authVM.errorMessage = "Password minimal 8 karakter."; return }

            // Masukkan data ke ViewModel dan jalankan Register
            authVM.name = nameTrim
            authVM.email = emailTrim
            authVM.password = regPassword
            await authVM.register()
            
            // Jika berhasil daftar, refresh data profil dan tutup sheet
            if authVM.isLoggedIn {
                await vm.initializeUserProfile()
                dismiss()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    AuthView(vm: ProfileViewModel(), initialMode: .login)
}

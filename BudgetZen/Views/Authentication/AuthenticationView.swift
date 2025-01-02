import SwiftUI
import LocalAuthentication

struct AuthenticationView: View {
    @StateObject private var authService = AuthenticationService.shared
    @AppStorage("usePIN") private var usePIN = false
    @State private var pin = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            if usePIN {
                SecureField("Code PIN", text: $pin)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button("Déverrouiller") {
                    verifyPIN()
                }
                .buttonStyle(.borderedProminent)
                .disabled(pin.count < 4)
            }
        }
        .padding()
        .onAppear {
            if !usePIN {
                authenticateWithBiometrics()
            }
        }
        .alert("Erreur", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func authenticateWithBiometrics() {
        Task {
            await authService.authenticate()
        }
    }
    
    private func verifyPIN() {
        if authService.verifyPIN(pin) {
            pin = ""
        } else {
            showError = true
            errorMessage = "Code PIN incorrect"
            pin = ""
        }
    }
} 
import SwiftUI
import LocalAuthentication

struct PINSettingsView: View {
    @AppStorage("usePIN") private var usePIN = false
    @AppStorage("pinCode") private var storedPIN = ""
    @AppStorage("useDevicePIN") private var useDevicePIN = false
    @AppStorage("useFaceID") private var useFaceID = false
    @State private var showingPINSetup = false
    @State private var showingDevicePINAlert = false
    @State private var pin = ""
    @State private var confirmPin = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isChangingPIN = false
    
    var body: some View {
        List {
            Section {
                Toggle("Utiliser un code PIN", isOn: $usePIN)
                    .onChange(of: usePIN) { _, newValue in
                        if newValue {
                            showingDevicePINAlert = true
                        } else {
                            authenticateToDisable()
                        }
                    }
            }
            
            if usePIN {
                Section {
                    Toggle("Utiliser le code de l'iPhone", isOn: $useDevicePIN)
                        .onChange(of: useDevicePIN) { _, newValue in
                            if newValue {
                                authenticateWithDevicePIN()
                            }
                        }
                    
                    if !useDevicePIN {
                        Button("Modifier le code PIN") {
                            isChangingPIN = true
                        }
                    }
                }
                
                Section {
                    Toggle("Utiliser Face ID", isOn: $useFaceID)
                        .onChange(of: useFaceID) { _, newValue in
                            if newValue {
                                checkBiometrics()
                            }
                        }
                }
            }
            
            if usePIN {
                Section(footer: Text(useDevicePIN ? "Le code de votre iPhone sera utilisé" : "Le code PIN sera demandé à chaque ouverture de l'application")) {
                    Text("Code PIN activé")
                        .foregroundColor(.green)
                }
            }
        }
        .navigationTitle("Code PIN")
        .sheet(isPresented: $showingPINSetup) {
            PINSetupView(pin: $pin, confirmPin: $confirmPin, showError: $showError, errorMessage: $errorMessage)
        }
        .sheet(isPresented: $isChangingPIN) {
            NavigationView {
                PINSetupView(pin: $pin, confirmPin: $confirmPin, showError: $showError, errorMessage: $errorMessage, isChangingPIN: true)
            }
        }
        .alert("Code de l'iPhone", isPresented: $showingDevicePINAlert) {
            Button("Utiliser le code de l'iPhone") {
                useDevicePIN = true
                authenticateWithDevicePIN()
            }
            Button("Créer un nouveau code") {
                useDevicePIN = false
                showingPINSetup = true
            }
            Button("Annuler", role: .cancel) {
                usePIN = false
                useDevicePIN = false
            }
        } message: {
            Text("Voulez-vous utiliser le même code que celui de votre iPhone ou créer un nouveau code ?")
        }
        .alert("Erreur", isPresented: $showError) {
            Button("OK", role: .cancel) {
                if !isChangingPIN {
                    usePIN = false
                    useDevicePIN = false
                    useFaceID = false
                }
            }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func authenticateWithDevicePIN() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication,
                                 localizedReason: "Confirmer l'utilisation du code de l'iPhone") { success, error in
                DispatchQueue.main.async {
                    if success {
                        usePIN = true
                        storedPIN = ""
                    } else {
                        usePIN = false
                        useDevicePIN = false
                        showError = true
                        errorMessage = "L'authentification a échoué"
                    }
                }
            }
        }
    }
    
    private func checkBiometrics() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                 localizedReason: "Activer Face ID") { success, error in
                DispatchQueue.main.async {
                    if !success {
                        useFaceID = false
                        showError = true
                        errorMessage = "L'activation de Face ID a échoué"
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                useFaceID = false
                showError = true
                errorMessage = "Face ID n'est pas disponible sur cet appareil"
            }
        }
    }
    
    private func authenticateToDisable() {
        if useDevicePIN {
            let context = LAContext()
            var error: NSError?
            
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                context.evaluatePolicy(.deviceOwnerAuthentication,
                                     localizedReason: "Confirmer la désactivation du code PIN") { success, error in
                    DispatchQueue.main.async {
                        if success {
                            usePIN = false
                            useDevicePIN = false
                            storedPIN = ""
                            useFaceID = false
                        } else {
                            showError = true
                            errorMessage = "L'authentification a échoué"
                            usePIN = true
                        }
                    }
                }
            }
        } else {
            usePIN = false
            useDevicePIN = false
            storedPIN = ""
            useFaceID = false
        }
    }
}

struct PINSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var pin: String
    @Binding var confirmPin: String
    @Binding var showError: Bool
    @Binding var errorMessage: String
    var isChangingPIN: Bool = false
    
    @AppStorage("pinCode") private var storedPIN = ""
    @AppStorage("usePIN") private var usePIN = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(isChangingPIN ? "Modifier le code PIN" : "Configurer le code PIN")
                    .font(.headline)
                
                SecureField("Entrez votre code PIN", text: $pin)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .multilineTextAlignment(.center)
                
                SecureField("Confirmez votre code PIN", text: $confirmPin)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .multilineTextAlignment(.center)
                
                Button("Enregistrer") {
                    savePIN()
                }
                .buttonStyle(.borderedProminent)
                .disabled(pin.count < 4 || confirmPin.count < 4)
            }
            .padding()
            .navigationBarItems(trailing: Button("Annuler") {
                pin = ""
                confirmPin = ""
                if !isChangingPIN {
                    usePIN = false
                }
                dismiss()
            })
        }
    }
    
    private func savePIN() {
        guard pin.count >= 4 else {
            showError = true
            errorMessage = "Le code PIN doit contenir au moins 4 chiffres"
            return
        }
        
        guard pin == confirmPin else {
            showError = true
            errorMessage = "Les codes PIN ne correspondent pas"
            return
        }
        
        storedPIN = pin
        usePIN = true
        dismiss()
    }
} 
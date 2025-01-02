import SwiftUI

struct PINSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var currentPIN = ""
    @State private var newPIN = ""
    @State private var confirmPIN = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        List {
            if viewModel.hasPIN {
                Section(header: Text("PIN actuel")) {
                    SecureField("Entrez votre PIN actuel", text: $currentPIN)
                        .keyboardType(.numberPad)
                }
            }
            
            Section(header: Text("Nouveau PIN")) {
                SecureField("Entrez un nouveau PIN", text: $newPIN)
                    .keyboardType(.numberPad)
                SecureField("Confirmez le nouveau PIN", text: $confirmPIN)
                    .keyboardType(.numberPad)
            }
            
            Section {
                Button(viewModel.hasPIN ? "Modifier le PIN" : "Définir le PIN") {
                    updatePIN()
                }
                .disabled(!canUpdatePIN)
                
                if viewModel.hasPIN {
                    Button("Supprimer le PIN", role: .destructive) {
                        viewModel.removePIN()
                    }
                }
            }
        }
        .navigationTitle("Code PIN")
        .alert("Erreur", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private var canUpdatePIN: Bool {
        if viewModel.hasPIN {
            return !currentPIN.isEmpty && newPIN.count == 4 && newPIN == confirmPIN
        } else {
            return newPIN.count == 4 && newPIN == confirmPIN
        }
    }
    
    private func updatePIN() {
        if viewModel.hasPIN {
            guard viewModel.validatePIN(currentPIN) else {
                errorMessage = "PIN actuel incorrect"
                showingError = true
                return
            }
        }
        
        guard newPIN.count == 4, CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: newPIN)) else {
            errorMessage = "Le PIN doit contenir 4 chiffres"
            showingError = true
            return
        }
        
        viewModel.updatePIN(newPIN)
    }
} 
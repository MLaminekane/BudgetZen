import SwiftUI
import LocalAuthentication

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showingResetAlert = false
    @State private var showingExportSheet = false
    
    var body: some View {
        NavigationView {
            List {
                // Apparence
                Section(header: Text("Apparence")) {
                    Toggle("Mode sombre", isOn: $isDarkMode)
                    
                    NavigationLink("Thème et couleurs") {
                        ThemeSettingsView(viewModel: viewModel)
                    }
                }
                
                // Sécurité
                Section(header: Text("Sécurité")) {
                    Toggle("Face ID / Touch ID", isOn: $viewModel.useBiometrics)
                        .onChange(of: viewModel.useBiometrics) { _, newValue in
                            if newValue {
                                viewModel.checkBiometrics()
                            }
                        }
                    
                    NavigationLink("Code PIN") {
                        PINSettingsView(viewModel: viewModel)
                    }
                }
                
                // Catégories
                Section(header: Text("Catégories")) {
                    NavigationLink("Gérer les catégories") {
                        CategoriesSettingsView(viewModel: viewModel)
                    }
                }
                
                // Notifications
                Section(header: Text("Notifications")) {
                    Toggle("Rappels de saisie", isOn: $viewModel.enableReminders)
                    Toggle("Alertes de budget", isOn: $viewModel.enableBudgetAlerts)
                    
                    if viewModel.enableReminders || viewModel.enableBudgetAlerts {
                        NavigationLink("Configurer les notifications") {
                            NotificationSettingsView(viewModel: viewModel)
                        }
                    }
                }
                
                // Préférences
                Section(header: Text("Préférences")) {
                    Picker("Devise", selection: $viewModel.selectedCurrency) {
                        ForEach(viewModel.availableCurrencies, id: \.code) { currency in
                            Text("\(currency.symbol) \(currency.name)").tag(currency.code)
                        }
                    }
                    
                    Picker("Langue", selection: $viewModel.selectedLanguage) {
                        ForEach(viewModel.availableLanguages, id: \.code) { language in
                            Text(language.name).tag(language.code)
                        }
                    }
                }
                
                // Synchronisation
                Section(header: Text("Synchronisation")) {
                    Toggle("Synchronisation iCloud", isOn: $viewModel.enableICloudSync)
                    
                    if viewModel.enableICloudSync {
                        HStack {
                            Text("Dernière synchronisation")
                            Spacer()
                            Text(viewModel.lastSyncDate?.formatted() ?? "Jamais")
                                .foregroundColor(.gray)
                        }
                        
                        Button("Synchroniser maintenant") {
                            viewModel.syncData()
                        }
                    }
                }
                
                // Exportation
                Section(header: Text("Exportation")) {
                    Button("Exporter les données") {
                        showingExportSheet = true
                    }
                }
                
                // Réinitialisation
                Section(header: Text("Réinitialisation")) {
                    Button("Réinitialiser toutes les données", role: .destructive) {
                        showingResetAlert = true
                    }
                }
                
                // À propos
                Section(header: Text("À propos")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(viewModel.appVersion)
                            .foregroundColor(.gray)
                    }
                    
                    NavigationLink("Mentions légales") {
                        LegalView()
                    }
                    
                    NavigationLink("Politique de confidentialité") {
                        PrivacyPolicyView()
                    }
                }
            }
            .navigationTitle("Réglages")
            .alert("Réinitialiser les données", isPresented: $showingResetAlert) {
                Button("Annuler", role: .cancel) {}
                Button("Réinitialiser", role: .destructive) {
                    viewModel.resetAllData()
                }
            } message: {
                Text("Cette action supprimera définitivement toutes vos données. Cette action est irréversible.")
            }
            .sheet(isPresented: $showingExportSheet) {
                ExportView(viewModel: viewModel)
            }
        }
    }
}

struct ThemeSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        List {
            Section(header: Text("Couleur principale")) {
                ColorPicker("Couleur", selection: $viewModel.accentColor)
            }
            
            Section(header: Text("Style")) {
                Picker("Style d'interface", selection: $viewModel.interfaceStyle) {
                    Text("Système").tag(InterfaceStyle.system)
                    Text("Clair").tag(InterfaceStyle.light)
                    Text("Sombre").tag(InterfaceStyle.dark)
                }
            }
        }
        .navigationTitle("Thème")
    }
}

struct ExportView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button("Exporter en CSV") {
                        viewModel.exportData(format: .csv)
                    }
                    
                    Button("Exporter en PDF") {
                        viewModel.exportData(format: .pdf)
                    }
                }
            }
            .navigationTitle("Exporter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Prévisualisation
#Preview {
    SettingsView()
} 
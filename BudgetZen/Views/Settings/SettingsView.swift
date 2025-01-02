import SwiftUI
import LocalAuthentication
import StoreKit

struct SettingsView: View {
    @StateObject private var viewModel = TransactionViewModel()
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("selectedCurrency") private var selectedCurrency = "CAD"
    @AppStorage("selectedLanguage") private var selectedLanguage = "fr"
    @AppStorage("userName") private var userName = ""
    @State private var showingResetAlert = false
    @State private var showingExportSheet = false
    @State private var showingProfileImagePicker = false
    @State private var profileImage: UIImage?
    @State private var isEditingProfile = false
    @Environment(\.requestReview) private var requestReview
    @State private var showingShareSheet = false
    @StateObject private var backupService = BackupService()
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showRestoreAlert = false
    @State private var isSignedInToGoogle = false
    
    private let currencies = [
        ("CAD", "$", "Dollar canadien"),
        ("USD", "$", "Dollar américain"),
        ("EUR", "€", "Euro"),
        ("GBP", "£", "Livre sterling")
    ]
    
    private let languages = [
        ("fr", "Français"),
        ("en", "English")
    ]
    
    var body: some View {
        NavigationView {
            List {
                // Profil utilisateur
                Section {
                    HStack {
                        // Image de profil avec bouton
                        Button(action: {
                            showingProfileImagePicker = true
                        }) {
                            if let image = profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            if isEditingProfile {
                                TextField("Nom d'utilisateur", text: $userName)
                            } else {
                                Text(userName.isEmpty ? "Utilisateur" : userName)
                                    .font(.headline)
                            }
                        }
                        .padding(.leading)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                isEditingProfile.toggle()
                            }
                        }) {
                            Image(systemName: isEditingProfile ? "checkmark.circle.fill" : "pencil")
                                .foregroundColor(isEditingProfile ? .green : .blue)
                        }
                    }
                }
                
                // Apparence
                Section(header: Text("Apparence")) {
                    Toggle("Mode sombre", isOn: $isDarkMode)
                        .animation(.easeInOut, value: isDarkMode)
                }
                
                // Préférences
                Section(header: Text("Préférences")) {
                    Picker("Devise", selection: $selectedCurrency) {
                        ForEach(currencies, id: \.0) { currency in
                            Text("\(currency.1) \(currency.2)").tag(currency.0)
                        }
                    }
                    
                    Picker("Langue", selection: $selectedLanguage) {
                        ForEach(languages, id: \.0) { language in
                            Text(language.1).tag(language.0)
                        }
                    }
                }
                
                // Sécurité
                Section(header: Text("Sécurité")) {
                    NavigationLink("Code PIN") {
                        PINSettingsView()
                    }
                }
                
                // Notifications
                Section(header: Text("Notifications")) {
                    NavigationLink("Configurer les notifications") {
                        NotificationSettingsView()
                    }
                }
                
                // Synchronisation
                Section(header: Text("Synchronisation")) {
                    Picker("Service de sauvegarde", selection: $backupService.selectedProvider) {
                        Text("iCloud").tag(BackupProvider.iCloud)
                        // On cache temporairement l'option Google Drive
                        // Text("Google Drive").tag(BackupProvider.googleDrive)
                    }
                    
                    Button(action: {
                        Task {
                            do {
                                try await backupService.backup()
                            } catch {
                                showError = true
                                errorMessage = error.localizedDescription
                            }
                        }
                    }) {
                        HStack {
                            Text("Sauvegarder maintenant")
                            if backupService.isBackingUp {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(backupService.isBackingUp)
                    
                    if let lastBackup = backupService.lastBackupDate {
                        HStack {
                            Text("Dernière sauvegarde")
                            Spacer()
                            Text(lastBackup.formatted())
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: {
                        showRestoreAlert = true
                    }) {
                        Text("Restaurer une sauvegarde")
                            .foregroundColor(.red)
                    }
                }
                
                // Réinitialisation
                Section {
                    Button(role: .destructive) {
                        showingResetAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Réinitialiser toutes les données")
                        }
                    }
                }
                
                // Support
                Section(header: Text("Support")) {
                    Button(action: {
                        requestReview()
                    }) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Noter l'application")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                            Text("Partager l'application")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // À propos
                Section(header: Text("À propos")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.appVersion)
                            .foregroundColor(.secondary)
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
            .sheet(isPresented: $showingProfileImagePicker) {
                ImagePicker(image: $profileImage)
            }
            .animation(.easeInOut, value: isEditingProfile)
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(items: [
                    "Découvrez BudgetZen, l'application qui simplifie la gestion de vos finances !",
                    URL(string: "https://apps.apple.com/app/budgetzen")!
                ])
            }
        }
    }
}

// Helper pour la sélection d'image
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
    }
}

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

// Ajouter cette structure pour le partage
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingsView()
} 
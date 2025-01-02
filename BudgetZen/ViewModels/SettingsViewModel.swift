import Foundation
import LocalAuthentication
import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var useBiometrics = false
    @Published var enableReminders = false
    @Published var enableBudgetAlerts = false
    @Published var selectedCurrency = "EUR"
    @Published var selectedLanguage = "fr"
    @Published var enableICloudSync = false
    @Published var accentColor = Color.blue
    @Published var interfaceStyle = InterfaceStyle.system
    @Published var lastSyncDate: Date?
    @Published var hasPIN = false
    @Published var reminderTime = Date()
    @Published var reminderFrequency = NotificationFrequency.daily
    @Published var alertOnOverspend = false
    @Published var budgetAlertThreshold = 80.0
    @Published var categories: [Category] = []
    @Published var editingCategory: Category? = nil
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    
    let availableCurrencies = [
        Currency(code: "EUR", name: "Euro", symbol: "€"),
        Currency(code: "USD", name: "Dollar US", symbol: "$"),
        Currency(code: "GBP", name: "Livre Sterling", symbol: "£")
    ]
    
    let availableLanguages = [
        Language(code: "fr", name: "Français"),
        Language(code: "en", name: "English"),
        Language(code: "es", name: "Español")
    ]
    
    func checkBiometrics() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                 localizedReason: "Activer l'authentification biométrique") { success, error in
                DispatchQueue.main.async {
                    self.useBiometrics = success
                }
            }
        } else {
            self.useBiometrics = false
        }
    }
    
    func syncData() {
        // Implémenter la synchronisation iCloud
        lastSyncDate = Date()
    }
    
    func resetAllData() {
        // Implémenter la réinitialisation des données
    }
    
    func exportData(format: ExportFormat) {
        // Implémentation de l'exportation
    }
    
    func validatePIN(_ pin: String) -> Bool {
        // Implémenter la validation du PIN
        return true
    }
    
    func updatePIN(_ pin: String) {
        // Implémenter la mise à jour du PIN
        hasPIN = true
    }
    
    func removePIN() {
        // Implémenter la suppression du PIN
        hasPIN = false
    }
    
    func updateNotificationSettings() {
        // Implémenter la mise à jour des notifications
    }
    
    func deleteCategories(at indexSet: IndexSet, type: TransactionType) {
        let filteredCategories = categories.filter { $0.type == type }
        indexSet.forEach { index in
            if let categoryToDelete = filteredCategories[safe: index],
               let actualIndex = categories.firstIndex(where: { $0.id == categoryToDelete.id }) {
                categories.remove(at: actualIndex)
            }
        }
    }
    
    func addCategory(_ category: Category) {
        categories.append(category)
    }
    
    func updateCategory(_ category: Category) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = category
        }
    }
    
    func nextCategoryOrder(for type: TransactionType) -> Int {
        let typeCategories = categories.filter { $0.type == type }
        return (typeCategories.map { $0.order }.max() ?? -1) + 1
    }
    
    func moveCategory(from source: IndexSet, to destination: Int, type: TransactionType) {
        var typeCategories = categories.filter { $0.type == type }
        typeCategories.move(fromOffsets: source, toOffset: destination)
        
        // Mettre à jour l'ordre
        for (index, var category) in typeCategories.enumerated() {
            category = Category(
                id: category.id,
                name: category.name,
                icon: category.icon,
                color: category.color,
                type: category.type,
                isDefault: category.isDefault,
                order: index
            )
            updateCategory(category)
        }
    }
    
    func resetToDefaultCategories() {
        categories = Category.defaultCategories
    }
    
    init() {
        categories = Category.defaultCategories
        // ... reste du code d'initialisation
    }
}

enum NotificationFrequency {
    case daily, weekly, monthly
} 

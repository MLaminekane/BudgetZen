import Foundation

enum BackupProvider {
    case local
    case iCloud
}

class BackupService: ObservableObject {
    static let shared = BackupService()
    
    @Published var lastBackupDate: Date?
    @Published var isBackingUp = false
    @Published var selectedProvider: BackupProvider = .local
    
    // Sauvegarder les données
    func backup() async throws {
        isBackingUp = true
        defer { isBackingUp = false }
        
        let data = try prepareBackupData()
        UserDefaults.standard.set(data, forKey: "localBackup")
        UserDefaults.standard.set(Date(), forKey: "lastBackupDate")
        
        await MainActor.run {
            lastBackupDate = Date()
        }
    }
    
    // Restaurer les données
    func restore() async throws {
        guard let data = UserDefaults.standard.data(forKey: "localBackup") else {
            throw BackupError.noBackupFound
        }
        
        try restoreFromData(data)
    }
    
    // Helpers
    private func prepareBackupData() throws -> Data {
        let backup = BackupData(
            transactions: UserDefaults.standard.data(forKey: "transactions"),
            categories: UserDefaults.standard.data(forKey: "categories"),
            budgets: UserDefaults.standard.data(forKey: "budgets"),
            settings: UserDefaults.standard.data(forKey: "settings")
        )
        
        return try JSONEncoder().encode(backup)
    }
    
    private func restoreFromData(_ data: Data) throws {
        let backup = try JSONDecoder().decode(BackupData.self, from: data)
        
        UserDefaults.standard.set(backup.transactions, forKey: "transactions")
        UserDefaults.standard.set(backup.categories, forKey: "categories")
        UserDefaults.standard.set(backup.budgets, forKey: "budgets")
        UserDefaults.standard.set(backup.settings, forKey: "settings")
        UserDefaults.standard.synchronize()
    }
}

struct BackupData: Codable {
    let transactions: Data?
    let categories: Data?
    let budgets: Data?
    let settings: Data?
}

enum BackupError: Error {
    case notAuthenticated
    case noBackupFound
    case invalidData
} 
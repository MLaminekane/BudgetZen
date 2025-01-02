import Foundation
import LocalAuthentication
import CoreData

class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var categories: [Category] = []
    @Published var budgets: [Budget] = []
    @Published var useBiometrics: Bool = false
    @Published var enableICloudSync: Bool = false
    @Published var lastSyncDate: Date?
    
    private let viewContext: NSManagedObjectContext
    
    // Initializer par défaut
    convenience init() {
        // Obtenir le contexte par défaut
        let context = PersistenceController.shared.container.viewContext
        self.init(context: context)
    }
    
    // Initializer principal
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        loadCategories()
        loadTransactions()
        loadBudgets()
    }
    
    func loadCategories() {
        // Charger depuis UserDefaults ou CoreData
        if let savedCategories = UserDefaults.standard.data(forKey: "categories"),
           let decodedCategories = try? JSONDecoder().decode([Category].self, from: savedCategories) {
            categories = decodedCategories
        } else {
            // Catégories par défaut si aucune n'est sauvegardée
            categories = Category.defaultCategories
            saveCategories()
        }
    }
    
    func saveCategories() {
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: "categories")
        }
    }
    
    func addCategory(_ category: Category) {
        categories.append(category)
        saveCategories()
    }
    
    func deleteCategory(_ category: Category) {
        categories.removeAll { $0.id == category.id }
        // Supprimer aussi les budgets associés
        budgets.removeAll { $0.category.id == category.id }
        saveCategories()
        saveBudgets()
    }
    
    func updateCategory(_ category: Category) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = category
            saveCategories()
            // Mettre à jour les budgets associés
            updateBudgetsForCategory(category)
        }
    }
    
    // MARK: - Gestion des budgets
    
    func loadBudgets() {
        if let savedBudgets = UserDefaults.standard.data(forKey: "budgets"),
           let decodedBudgets = try? JSONDecoder().decode([Budget].self, from: savedBudgets) {
            budgets = decodedBudgets
        } else {
            // Créer des budgets par défaut pour les catégories de dépenses
            createDefaultBudgets()
        }
    }
    
    private func createDefaultBudgets() {
        budgets = categories.filter { $0.type == .expense }.map { category in
            Budget(
                id: UUID(),
                category: category,
                limit: 1000,
                period: .month
            )
        }
        saveBudgets()
    }
    
    func saveBudgets() {
        if let encoded = try? JSONEncoder().encode(budgets) {
            UserDefaults.standard.set(encoded, forKey: "budgets")
        }
    }
    
    func updateBudget(_ budget: Budget) {
        if let index = budgets.firstIndex(where: { $0.id == budget.id }) {
            budgets[index] = budget
            saveBudgets()
        }
    }
    
    private func updateBudgetsForCategory(_ category: Category) {
        for (index, budget) in budgets.enumerated() {
            if budget.category.id == category.id {
                budgets[index] = Budget(
                    id: budget.id,
                    category: category,
                    limit: budget.limit,
                    period: budget.period
                )
            }
        }
        saveBudgets()
    }
    
    // MARK: - Helpers pour les catégories
    
    func category(for id: UUID) -> Category? {
        categories.first(where: { $0.id == id })
    }
    
    var expenseCategories: [Category] {
        categories.filter { $0.type == .expense }
    }
    
    var incomeCategories: [Category] {
        categories.filter { $0.type == .income }
    }
    
    func loadTransactions() {
        // À implémenter : chargement depuis CoreData ou UserDefaults
    }
    
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        // Le @Published se chargera de la notification
        // objectWillChange.send() n'est plus nécessaire
    }
    
    func deleteTransaction(at offsets: IndexSet) {
        transactions.remove(atOffsets: offsets)
        // À implémenter : sauvegarde
    }
    
    func filteredTransactions(type: TransactionType?) -> [Transaction] {
        guard let type = type else { return transactions }
        return transactions.filter { $0.type == type }
    }
    
    var totalBalance: Double {
        transactions.reduce(0) { $0 + $1.amount }
    }
    
    func periodIncome(for period: DashboardView.Period) -> Double {
        let filteredTransactions = filterTransactions(for: period)
        return filteredTransactions.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
    }
    
    func periodExpenses(for period: DashboardView.Period) -> Double {
        let filteredTransactions = filterTransactions(for: period)
        return abs(filteredTransactions.filter { $0.amount < 0 }.reduce(0) { $0 + $1.amount })
    }
    
    func filterTransactions(for period: DashboardView.Period) -> [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        
        let startDate: Date
        switch period {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now)!
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now)!
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now)!
        }
        
        return transactions.filter { $0.date >= startDate && $0.date <= now }
    }
    
    func transactionsByDay(for period: DashboardView.Period) -> [(date: Date, amount: Double)] {
        let filteredTransactions = filterTransactions(for: period)
        let groupedByDay = Dictionary(grouping: filteredTransactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
        
        return groupedByDay.map { (date, transactions) in
            (date: date, amount: transactions.reduce(0) { $0 + $1.amount })
        }.sorted { $0.date < $1.date }
    }
    
    var recentTransactions: [Transaction] {
        transactions.sorted { $0.date > $1.date }
    }
    
    func spentAmount(for category: Category) -> Double {
        abs(transactions.filter { $0.categoryId == category.id && $0.amount < 0 }
            .reduce(0) { $0 + $1.amount })
    }
    
    var activeSubscriptions: [Transaction] {
        transactions.filter { $0.isRecurring }
    }
    
    func deleteAllData() {
        transactions.removeAll()
        categories = Category.defaultCategories
        budgets.removeAll()
        saveTransactions()
        saveCategories()
        saveBudgets()
    }
    
    func saveTransactions() {
        if let encoded = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(encoded, forKey: "transactions")
        }
    }
    
    func checkBiometrics() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Activer l'authentification biométrique") { success, error in
                DispatchQueue.main.async {
                    self.useBiometrics = success
                }
            }
        }
    }
    
    func exportData(format: ExportFormat) {
        // Implémentation de l'exportation
        switch format {
        case .csv:
            // Logique d'exportation CSV
            print("Exporting to CSV...")
        case .pdf:
            // Logique d'exportation PDF
            print("Exporting to PDF...")
        }
    }
    
    func nextCategoryOrder(for type: TransactionType) -> Int {
        let typeCategories = categories.filter { $0.type == type }
        return (typeCategories.map { $0.order }.max() ?? -1) + 1
    }
    
    func resetAllData() {
        // Supprimer les données de la mémoire
        transactions.removeAll()
        categories = Category.defaultCategories
        budgets.removeAll()
        
        // Supprimer les données de UserDefaults
        UserDefaults.standard.removeObject(forKey: "transactions")
        UserDefaults.standard.removeObject(forKey: "categories")
        UserDefaults.standard.removeObject(forKey: "budgets")
        
        // Forcer UserDefaults à sauvegarder immédiatement
        UserDefaults.standard.synchronize()
        
        // Sauvegarder l'état initial (catégories par défaut)
        saveCategories()
        saveBudgets()
        
        // Réinitialiser les totaux et notifier l'interface
        objectWillChange.send()
    }
} 
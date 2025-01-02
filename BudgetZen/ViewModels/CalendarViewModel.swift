import Foundation

class CalendarViewModel: ObservableObject {
    private let calendar = Calendar.current
    
    @Published var selectedDate = Date()
    @Published var selectedViewMode: ViewMode = .month
    @Published var transactions: [Date: [Transaction]] = [:]
    @Published var selectedCategories: Set<UUID> = []
    @Published var selectedTypes: Set<TransactionType> = [.expense, .income]
    @Published var showingAddTransaction = false
    @Published var periodStatistics = PeriodStatistics()
    @Published var categories: [Category] = []
    
    init() {
        categories = [
            Category(name: "Alimentation", icon: "cart.fill", color: "#FF6B6B", type: .expense),
            Category(name: "Transport", icon: "car.fill", color: "#4ECDC4", type: .expense),
            Category(name: "Loisirs", icon: "gamecontroller.fill", color: "#45B7D1", type: .expense),
            Category(name: "Salaire", icon: "dollarsign.circle.fill", color: "#2ECC71", type: .income)
        ]
    }
    
    enum ViewMode: String, CaseIterable {
        case month = "Mois"
        case week = "Semaine"
    }
    
    struct PeriodStatistics {
        var totalExpenses: Double = 0
        var totalIncome: Double = 0
        var topCategories: [(Category, Double)] = []
        var dailyAverageExpense: Double = 0
        var dailyAverageIncome: Double = 0
        
        var balance: Double {
            totalIncome - totalExpenses
        }
    }
    
    // Structure pour stocker les totaux quotidiens
    struct DayTotal {
        var expenses: Double = 0
        var income: Double = 0
        
        var total: Double {
            income - expenses
        }
    }
    
    func getDayTotal(for date: Date) -> DayTotal {
        guard let dayTransactions = getFilteredTransactions(for: date) else { return DayTotal() }
        
        var total = DayTotal()
        for transaction in dayTransactions {
            if transaction.type == .expense {
                total.expenses += transaction.amount
            } else {
                total.income += transaction.amount
            }
        }
        return total
    }
    
    func getFilteredTransactions(for date: Date) -> [Transaction]? {
        guard let dayTransactions = transactions[date] else { return nil }
        return dayTransactions.filter { transaction in
            selectedTypes.contains(transaction.type) &&
            (selectedCategories.isEmpty || selectedCategories.contains(transaction.categoryId))
        }
    }
    
    func updatePeriodStatistics() {
        var stats = PeriodStatistics()
        var categoryTotals: [UUID: Double] = [:]
        var daysWithTransactions = 0
        
        let calendar = Calendar.current
        let periodStart: Date
        let periodEnd: Date
        
        switch selectedViewMode {
        case .week:
            periodStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
            periodEnd = calendar.date(byAdding: .day, value: 7, to: periodStart)!
        case .month:
            periodStart = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
            periodEnd = calendar.date(byAdding: .month, value: 1, to: periodStart)!
        }
        
        for (date, dayTransactions) in transactions {
            guard date >= periodStart && date < periodEnd else { continue }
            
            if !dayTransactions.isEmpty {
                daysWithTransactions += 1
            }
            
            for transaction in dayTransactions {
                if transaction.type == .expense {
                    stats.totalExpenses += transaction.amount
                    categoryTotals[transaction.categoryId, default: 0] += transaction.amount
                } else {
                    stats.totalIncome += transaction.amount
                }
            }
        }
        
        // Calculer les moyennes quotidiennes
        let numberOfDays = calendar.dateComponents([.day], from: periodStart, to: periodEnd).day ?? 1
        stats.dailyAverageExpense = stats.totalExpenses / Double(numberOfDays)
        stats.dailyAverageIncome = stats.totalIncome / Double(numberOfDays)
        
        // Trier les catégories par montant
        stats.topCategories = categoryTotals
            .sorted { $0.value > $1.value }
            .prefix(5)
            .compactMap { categoryId, amount in
                guard let category = getCategoryById(categoryId) else { return nil }
                return (category, amount)
            }
        
        periodStatistics = stats
    }
    
    // À implémenter : obtenir une catégorie par son ID
    private func getCategoryById(_ id: UUID) -> Category? {
        // Pour le moment, retournons une catégorie factice
        return Category(name: "Catégorie", icon: "cart.fill", color: "#FF6B6B", type: .expense)
    }
    
    func loadTransactions(for date: Date) {
        let testData = generateTestData(for: date)
        transactions = Dictionary(grouping: testData) { transaction in
            calendar.startOfDay(for: transaction.date)
        }
        updatePeriodStatistics()
    }
    
    private func generateTestData(for date: Date) -> [Transaction] {
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let firstDayOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: date) else {
            return []
        }
        
        return (1...range.count).flatMap { day -> [Transaction] in
            guard Int.random(in: 0...2) > 0 else { return [] }
            
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) else {
                return []
            }
            
            let isExpense = Bool.random()
            return [
                Transaction(
                    amount: Double.random(in: 10...200),
                    title: isExpense ? "Dépense test" : "Revenu test",
                    date: date,
                    type: isExpense ? .expense : .income,
                    categoryId: UUID()
                )
            ]
        }
    }
} 
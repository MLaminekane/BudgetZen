import Foundation
import SwiftUI

class DashboardViewModel: ObservableObject {
    @Published var balance: Double = 0
    @Published var periodExpenses: Double = 0
    @Published var periodIncome: Double = 0
    @Published var selectedPeriod: Period = .month
    @Published var recentTransactions: [Transaction] = []
    @Published var activeSubscriptions: [Transaction] = []
    @Published var budgetProgress: [BudgetProgress] = []
    
    enum Period: String, CaseIterable {
        case week = "Semaine"
        case month = "Mois"
        case year = "Année"
    }
    
    struct BudgetProgress: Identifiable {
        let id = UUID()
        let category: Category
        let spent: Double
        let limit: Double
        
        var percentage: Double {
            (spent / limit) * 100
        }
    }
    
    func loadDashboardData() {
        // À implémenter : charger les données depuis la persistance
        // Pour le moment, utilisons des données de test
        balance = 2500.0
        periodExpenses = 1200.0
        periodIncome = 3000.0
        
        // Simuler des données de progression de budget
        budgetProgress = [
            BudgetProgress(
                category: Category(name: "Alimentation", icon: "cart.fill", color: "#FF6B6B", type: .expense),
                spent: 350,
                limit: 500
            ),
            BudgetProgress(
                category: Category(name: "Transport", icon: "car.fill", color: "#4ECDC4", type: .expense),
                spent: 120,
                limit: 200
            )
        ]
    }
} 
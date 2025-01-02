import Foundation

enum TransactionType: String, Codable, CaseIterable, Hashable {
    case income = "Revenus"
    case expense = "Dépenses"
} 
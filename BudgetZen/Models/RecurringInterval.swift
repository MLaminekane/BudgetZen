import Foundation

enum RecurringInterval: String, Codable, CaseIterable {
    case daily = "Quotidien"
    case weekly = "Hebdomadaire"
    case monthly = "Mensuel"
    case yearly = "Annuel"
} 
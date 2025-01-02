import SwiftUI

struct Category: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var icon: String
    var color: String
    var type: TransactionType
    var isDefault: Bool
    var order: Int
    
    var uiColor: Color {
        Color(hex: color)
    }
    
    init(id: UUID = UUID(), name: String, icon: String, color: String, type: TransactionType, isDefault: Bool = false, order: Int = 0) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.type = type
        self.isDefault = isDefault
        self.order = order
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, name, icon, color, type, isDefault, order
    }
}

// Extension pour les catégories par défaut
extension Category {
    static var defaultCategories: [Category] {
        [
            // Revenus
            Category(name: "Salaire", icon: "dollarsign.circle.fill", color: "#2ECC71", type: .income, isDefault: true, order: 0),
            Category(name: "Freelance", icon: "briefcase.fill", color: "#27AE60", type: .income, isDefault: true, order: 1),
            
            // Dépenses
            Category(name: "Alimentation", icon: "cart.fill", color: "#E74C3C", type: .expense, isDefault: true, order: 0),
            Category(name: "Transport", icon: "car.fill", color: "#3498DB", type: .expense, isDefault: true, order: 1),
            Category(name: "Logement", icon: "house.fill", color: "#9B59B6", type: .expense, isDefault: true, order: 2)
        ]
    }
} 
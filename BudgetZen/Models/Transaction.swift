import Foundation

struct Transaction: Identifiable, Equatable, Encodable {
    let id: UUID
    let amount: Double
    let title: String
    let date: Date
    let type: TransactionType
    let categoryId: UUID
    let note: String?
    let isRecurring: Bool
    let recurringInterval: RecurringInterval?
    
    var category: Category? {
        nil
    }
    
    init(id: UUID = UUID(), amount: Double, title: String, date: Date, type: TransactionType, categoryId: UUID, note: String? = nil, isRecurring: Bool = false, recurringInterval: RecurringInterval? = nil) {
        self.id = id
        self.amount = amount
        self.title = title
        self.date = date
        self.type = type
        self.categoryId = categoryId
        self.note = note
        self.isRecurring = isRecurring
        self.recurringInterval = recurringInterval
    }
    
    static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        lhs.id == rhs.id
    }
} 
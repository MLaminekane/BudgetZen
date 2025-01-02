import Foundation

struct Budget: Identifiable, Codable {
    let id: UUID
    let category: Category
    var limit: Double
    var period: Period
    
    enum Period: String, Codable {
        case week, month, year
    }
} 
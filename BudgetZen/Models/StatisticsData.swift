import Foundation

struct StatisticsData: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
    let categoryId: UUID
    let type: TransactionType
}

enum StatisticsPeriod: String, CaseIterable {
    case day = "Jour"
    case week = "Semaine"
    case month = "Mois"
    case year = "Année"
    
    var calendarComponent: Calendar.Component {
        switch self {
        case .day: return .day
        case .week: return .weekOfYear
        case .month: return .month
        case .year: return .year
        }
    }
}

enum ChartType: String, CaseIterable {
    case bar = "Barres"
    case line = "Lignes"
    case area = "Aires"
} 
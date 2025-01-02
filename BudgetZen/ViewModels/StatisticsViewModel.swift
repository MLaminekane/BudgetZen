import SwiftUI
import Charts
import Combine

class StatisticsViewModel: ObservableObject {
    @Published var selectedPeriod: StatisticsPeriod = .month
    @Published var selectedChartType: ChartType = .bar
    @Published var selectedDateRange: ClosedRange<Date>
    @Published var compareWithPreviousPeriod = false
    @Published var selectedCategories: Set<UUID> = []
    @Published var selectedDataPoint: StatisticsData?
    
    private let transactionViewModel: TransactionViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(transactionViewModel: TransactionViewModel) {
        self.transactionViewModel = transactionViewModel
        let now = Date()
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: now)!
        self.selectedDateRange = oneMonthAgo...now
        
        // Observer les changements des transactions
        transactionViewModel.$transactions
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    func statisticsData(for type: TransactionType) -> [StatisticsData] {
        let transactions = transactionViewModel.transactions
            .filter { $0.type == type }
            .filter { selectedDateRange.contains($0.date) }
            .filter { selectedCategories.isEmpty || selectedCategories.contains($0.categoryId) }
        
        print("Données statistiques pour \(type):")
        print("- Total transactions: \(transactionViewModel.transactions.count)")
        print("- Transactions filtrées: \(transactions.count)")
        print("- Plage de dates: \(selectedDateRange.lowerBound) à \(selectedDateRange.upperBound)")
        
        return transactions.map { transaction in
            StatisticsData(
                date: transaction.date,
                amount: transaction.amount,
                categoryId: transaction.categoryId,
                type: transaction.type
            )
        }.sorted(by: { $0.date < $1.date })
    }
    
    func categoryTotal(for categoryId: UUID, in data: [StatisticsData]) -> Double {
        data.filter { $0.categoryId == categoryId }
            .reduce(0) { $0 + $1.amount }
    }
    
    func periodTotal(for data: [StatisticsData]) -> Double {
        data.reduce(0) { $0 + $1.amount }
    }
    
    func previousPeriodData(for type: TransactionType) -> [StatisticsData]? {
        guard compareWithPreviousPeriod else { return nil }
        
        let periodLength = selectedDateRange.upperBound.timeIntervalSince(selectedDateRange.lowerBound)
        let previousRange = (selectedDateRange.lowerBound - periodLength)...(selectedDateRange.lowerBound)
        
        return transactionViewModel.transactions
            .filter { $0.type == type }
            .filter { previousRange.contains($0.date) }
            .filter { selectedCategories.isEmpty || selectedCategories.contains($0.categoryId) }
            .map { transaction in
                StatisticsData(
                    date: transaction.date,
                    amount: transaction.amount,
                    categoryId: transaction.categoryId,
                    type: transaction.type
                )
            }
    }
    
    func updateDateRange(for period: StatisticsPeriod) {
        let calendar = Calendar.current
        let now = Date()
        
        let startDate: Date
        switch period {
        case .day:
            startDate = calendar.startOfDay(for: now)
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now)!
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now)!
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now)!
        }
        
        selectedDateRange = startDate...now
    }
    
    func groupedData(for type: TransactionType) -> [(String, Double)] {
        let data = statisticsData(for: type)
        let calendar = Calendar.current
        
        let grouped = Dictionary(grouping: data) { item -> String in
            switch selectedPeriod {
            case .day:
                return calendar.date(from: calendar.dateComponents([.hour], from: item.date))!
                    .formatted(date: .omitted, time: .shortened)
            case .week:
                return calendar.date(from: calendar.dateComponents([.weekday], from: item.date))!
                    .formatted(.dateTime.weekday(.wide))
            case .month:
                return calendar.date(from: calendar.dateComponents([.day], from: item.date))!
                    .formatted(.dateTime.day())
            case .year:
                return calendar.date(from: calendar.dateComponents([.month], from: item.date))!
                    .formatted(.dateTime.month(.wide))
            }
        }
        
        return grouped.map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.0 < $1.0 }
    }
    
    func categoryName(for id: UUID) -> String {
        transactionViewModel.categories.first { $0.id == id }?.name ?? "Inconnu"
    }
    
    func category(for id: UUID) -> Category? {
        transactionViewModel.category(for: id)
    }
    
    func categoryColor(_ category: Category) -> Color {
        category.uiColor
    }
    
    var categoryColors: [Color] {
        transactionViewModel.categories.map { $0.uiColor }
    }
    
    var categoryNames: [String] {
        let categories = transactionViewModel.categories
        return categories.map { categoryName(for: $0.id) }
    }
    
    // Ajoutons une méthode pour charger des données initiales
    func loadInitialData() {
        // Assurons-nous d'avoir une plage de dates raisonnable
        let calendar = Calendar.current
        let now = Date()
        let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
        selectedDateRange = oneMonthAgo...now
        
        // Forçons une mise à jour
        objectWillChange.send()
    }
} 
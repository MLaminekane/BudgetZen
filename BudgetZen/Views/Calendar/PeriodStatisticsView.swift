import SwiftUI

struct PeriodStatisticsView: View {
    let statistics: CalendarViewModel.PeriodStatistics
    
    var body: some View {
        VStack(spacing: 16) {
            // Totaux de la période
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Dépenses")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(String(format: "%.2f €", statistics.totalExpenses))
                        .font(.headline)
                        .foregroundColor(.red)
                }
                
                VStack(alignment: .leading) {
                    Text("Revenus")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(String(format: "%.2f €", statistics.totalIncome))
                        .font(.headline)
                        .foregroundColor(.green)
                }
            }
            
            // Moyennes quotidiennes
            VStack(alignment: .leading, spacing: 8) {
                Text("Moyennes quotidiennes")
                    .font(.headline)
                    .padding(.bottom, 4)
                
                HStack {
                    Text("Dépenses:")
                    Spacer()
                    Text(String(format: "%.2f €", statistics.dailyAverageExpense))
                        .foregroundColor(.red)
                }
                
                HStack {
                    Text("Revenus:")
                    Spacer()
                    Text(String(format: "%.2f €", statistics.dailyAverageIncome))
                        .foregroundColor(.green)
                }
            }
            
            // Top catégories
            if !statistics.topCategories.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Top catégories")
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    ForEach(statistics.topCategories, id: \.0.id) { category, amount in
                        HStack {
                            Image(systemName: category.icon)
                                .foregroundColor(category.uiColor)
                            Text(category.name)
                            Spacer()
                            Text(String(format: "%.2f €", amount))
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }
}

struct StatCard: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(String(format: "%.2f €", amount))
                .font(.headline)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
} 
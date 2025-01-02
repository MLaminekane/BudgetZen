import SwiftUI

struct StatisticsSummaryView: View {
    @ObservedObject var viewModel: StatisticsViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            if let selectedData = viewModel.selectedDataPoint {
                HStack {
                    VStack(alignment: .leading) {
                        Text(selectedData.date.formatted(date: .long, time: .omitted))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(String(format: "%.2f €", selectedData.amount))
                            .font(.title2.bold())
                    }
                    
                    Spacer()
                    
                    Button {
                        viewModel.selectedDataPoint = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                HStack(spacing: 20) {
                    StatisticsCard(
                        title: "Dépenses",
                        amount: viewModel.periodTotal(for: viewModel.statisticsData(for: .expense)),
                        color: .red
                    )
                    
                    StatisticsCard(
                        title: "Revenus",
                        amount: viewModel.periodTotal(for: viewModel.statisticsData(for: .income)),
                        color: .green
                    )
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct StatisticsCard: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(String(format: "%.2f €", amount))
                .font(.headline)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
} 
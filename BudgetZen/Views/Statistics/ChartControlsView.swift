import SwiftUI

struct ChartControlsView: View {
    @ObservedObject var viewModel: StatisticsViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ChartType.allCases, id: \.self) { type in
                    ChartTypeButton(
                        type: type,
                        isSelected: viewModel.selectedChartType == type,
                        action: { viewModel.selectedChartType = type }
                    )
                }
                
                Divider()
                    .frame(height: 24)
                
                ForEach(StatisticsPeriod.allCases, id: \.self) { period in
                    PeriodButton(
                        period: period,
                        isSelected: viewModel.selectedPeriod == period,
                        action: { 
                            viewModel.selectedPeriod = period
                            updateDateRange(for: period)
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func updateDateRange(for period: StatisticsPeriod) {
        let calendar = Calendar.current
        let now = Date()
        
        let startDate: Date
        switch period {
        case .day:
            startDate = calendar.startOfDay(for: now)
        case .week:
            startDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        case .month:
            startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        case .year:
            startDate = calendar.date(from: calendar.dateComponents([.year], from: now))!
        }
        
        viewModel.selectedDateRange = startDate...now
    }
}

struct ChartTypeButton: View {
    let type: ChartType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: iconName)
                Text(type.rawValue)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color(.tertiarySystemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(8)
        }
    }
    
    private var iconName: String {
        switch type {
        case .bar: return "chart.bar.fill"
        case .line: return "chart.line.uptrend.xyaxis"
        case .area: return "chart.area.fill"
        }
    }
}

struct PeriodButton: View {
    let period: StatisticsPeriod
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(period.rawValue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(.tertiarySystemBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
    }
} 
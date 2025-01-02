import SwiftUI
import Charts

struct StatisticsChartView: View {
    @ObservedObject var viewModel: StatisticsViewModel
    let type: TransactionType
    let title: String
    
    @GestureState private var dragLocation: CGPoint?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Données: \(viewModel.statisticsData(for: type).count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Période: \(viewModel.selectedDateRange.lowerBound.formatted()) - \(viewModel.selectedDateRange.upperBound.formatted())")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if viewModel.statisticsData(for: type).isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.downtrend.xyaxis")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("Aucune donnée pour cette période")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Chart {
                    ForEach(viewModel.statisticsData(for: type)) { data in
                        switch viewModel.selectedChartType {
                        case .bar:
                            BarMark(
                                x: .value("Date", data.date),
                                y: .value("Montant", data.amount)
                            )
                            .foregroundStyle(viewModel.categoryColor(viewModel.category(for: data.categoryId) ?? Category.defaultCategories[0]))
                        
                        case .line:
                            LineMark(
                                x: .value("Date", data.date),
                                y: .value("Montant", data.amount)
                            )
                            .foregroundStyle(viewModel.categoryColor(viewModel.category(for: data.categoryId) ?? Category.defaultCategories[0]))
                        
                        case .area:
                            AreaMark(
                                x: .value("Date", data.date),
                                y: .value("Montant", data.amount)
                            )
                            .foregroundStyle(viewModel.categoryColor(viewModel.category(for: data.categoryId) ?? Category.defaultCategories[0]))
                        }
                        
                        if viewModel.selectedChartType != .area {
                            PointMark(
                                x: .value("Date", data.date),
                                y: .value("Montant", data.amount)
                            )
                            .foregroundStyle(viewModel.categoryColor(viewModel.category(for: data.categoryId) ?? Category.defaultCategories[0]))
                        }
                    }
                    
                    if let previousData = viewModel.previousPeriodData(for: type),
                       case .line = viewModel.selectedChartType {
                        ForEach(previousData) { data in
                            LineMark(
                                x: .value("Date précédente", data.date),
                                y: .value("Montant précédent", data.amount)
                            )
                            .foregroundStyle(.gray.opacity(0.5))
                            .lineStyle(StrokeStyle(dash: [5, 5]))
                        }
                    }
                }
                .frame(height: 300)
                .chartXScale(domain: viewModel.selectedDateRange)
                .chartLegend(position: .bottom)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle().fill(.clear).contentShape(Rectangle())
                            .gesture(DragGesture()
                                .updating($dragLocation) { value, state, _ in
                                    state = value.location
                                }
                                .onEnded { value in
                                    if let date: Date = proxy.value(atX: value.location.x),
                                       let data = viewModel.statisticsData(for: type)
                                        .min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) }) {
                                        viewModel.selectedDataPoint = data
                                    }
                                }
                            )
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
        .onAppear {
            // Débogage à l'apparition
            print("Type: \(type)")
            print("Période: \(viewModel.selectedPeriod)")
            print("Plage de dates: \(viewModel.selectedDateRange)")
            print("Nombre de transactions: \(viewModel.statisticsData(for: type).count)")
        }
    }
} 
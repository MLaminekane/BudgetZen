import SwiftUI

struct StatisticsFiltersView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: StatisticsViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Période")) {
                    Picker("Période", selection: $viewModel.selectedPeriod) {
                        ForEach(StatisticsPeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    
                    DatePicker("Du", selection: .init(
                        get: { viewModel.selectedDateRange.lowerBound },
                        set: { viewModel.selectedDateRange = $0...viewModel.selectedDateRange.upperBound }
                    ), displayedComponents: [.date])
                    
                    DatePicker("Au", selection: .init(
                        get: { viewModel.selectedDateRange.upperBound },
                        set: { viewModel.selectedDateRange = viewModel.selectedDateRange.lowerBound...$0 }
                    ), displayedComponents: [.date])
                }
                
                Section(header: Text("Affichage")) {
                    Picker("Type de graphique", selection: $viewModel.selectedChartType) {
                        ForEach(ChartType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    Toggle("Comparer avec la période précédente", isOn: $viewModel.compareWithPreviousPeriod)
                }
            }
            .navigationTitle("Filtres")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
} 
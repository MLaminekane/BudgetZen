import SwiftUI
import Charts

struct StatisticsView: View {
    @StateObject private var viewModel: StatisticsViewModel
    @ObservedObject var transactionViewModel: TransactionViewModel
    @State private var showingFilters = false
    @State private var selectedTab = 0
    
    init(transactionViewModel: TransactionViewModel) {
        self._viewModel = StateObject(wrappedValue: StatisticsViewModel(transactionViewModel: transactionViewModel))
        self.transactionViewModel = transactionViewModel
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Carte de résumé avec effet glassmorphism
                    StatisticsSummaryView(viewModel: viewModel)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(radius: 5)
                        .padding(.horizontal)
                    
                    // Contrôles de période avec style moderne
                    ChartControlsView(viewModel: viewModel)
                        .padding(.horizontal)
                    
                    // Sélecteur de type de graphique
                    Picker("Type", selection: $selectedTab) {
                        Text("Dépenses").tag(0)
                        Text("Revenus").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Zone des graphiques avec animation
                    TabView(selection: $selectedTab) {
                        StatisticsChartView(
                            viewModel: viewModel,
                            type: .expense,
                            title: "Dépenses"
                        )
                        .tag(0)
                        
                        StatisticsChartView(
                            viewModel: viewModel,
                            type: .income,
                            title: "Revenus"
                        )
                        .tag(1)
                    }
                    .frame(height: 400)
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                .padding(.vertical)
            }
            .navigationTitle("Statistiques")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingFilters = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundStyle(.primary)
                            .font(.system(size: 20))
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                StatisticsFiltersView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.loadInitialData()
            }
            .onChange(of: transactionViewModel.transactions) { _ in
                viewModel.loadInitialData()
            }
        }
    }
} 
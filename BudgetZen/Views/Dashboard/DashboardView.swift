import SwiftUI
import Charts

struct DashboardView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @State private var selectedPeriod: Period = .month
    @State private var showingFilters = false
    
    enum Period: String, CaseIterable {
        case week = "Semaine"
        case month = "Mois"
        case year = "Année"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Solde total et période
                    HeaderView(balance: viewModel.totalBalance,
                             selectedPeriod: $selectedPeriod)
                    
                    // Résumé Dépenses/Revenus
                    SummaryCardsView(income: viewModel.periodIncome(for: selectedPeriod),
                                   expenses: viewModel.periodExpenses(for: selectedPeriod))
                    
                    // Graphique
                    ChartSection(viewModel: viewModel, period: selectedPeriod)
                    
                    // Budgets et objectifs
//                    BudgetProgressSection(viewModel: viewModel)
                    
                    
                    // Transactions récentes
                    RecentTransactionsSection(viewModel: viewModel)
                }
                .padding()
            }
            .navigationTitle("Tableau de bord")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingFilters.toggle() }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                StatisticsFiltersView(viewModel: StatisticsViewModel(transactionViewModel: viewModel))
            }
        }
    }
}

// MARK: - Composants du tableau de bord
struct HeaderView: View {
    let balance: Double
    @Binding var selectedPeriod: DashboardView.Period
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Solde total")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(String(format: "%.2f €", balance))
                .font(.system(size: 34, weight: .bold))
            
            Picker("Période", selection: $selectedPeriod) {
                ForEach(DashboardView.Period.allCases, id: \.self) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct SummaryCardsView: View {
    let income: Double
    let expenses: Double
    
    var body: some View {
        HStack {
            SummaryCard(title: "Revenus",
                       amount: income,
                       color: .green,
                       icon: "arrow.down.circle.fill")
            
            SummaryCard(title: "Dépenses",
                       amount: expenses,
                       color: .red,
                       icon: "arrow.up.circle.fill")
        }
    }
}

struct SummaryCard: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
            }
            
            Text(String(format: "%.2f €", amount))
                .font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct ChartSection: View {
    let viewModel: TransactionViewModel
    let period: DashboardView.Period
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Aperçu")
                .font(.headline)
            
            Chart {
                ForEach(viewModel.transactionsByDay(for: period), id: \.date) { data in
                    BarMark(
                        x: .value("Date", data.date),
                        y: .value("Montant", data.amount)
                    )
                    .foregroundStyle(data.amount >= 0 ? Color.green : Color.red)
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct BudgetProgressSection: View {
    let viewModel: TransactionViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Budgets")
                .font(.headline)
            
            ForEach(viewModel.budgets) { budget in
                BudgetProgressRow(budget: budget,
                                spent: viewModel.spentAmount(for: budget.category))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}



struct RecentTransactionsSection: View {
    let viewModel: TransactionViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Transactions récentes")
                .font(.headline)
            
            ForEach(viewModel.recentTransactions.prefix(5)) { transaction in
                TransactionRow(transaction: transaction, viewModel: viewModel)
            }
            
            NavigationLink(destination: TransactionListView(viewModel: viewModel)) {
                Text("Voir toutes les transactions")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
} 

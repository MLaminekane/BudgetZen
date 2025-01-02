import SwiftUI

struct TransactionsView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @State private var showingAddTransaction = false
    @State private var selectedFilter: TransactionType?
    @State private var showingFilters = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredTransactions) { transaction in
                    NavigationLink {
                        TransactionDetailView(transaction: transaction, viewModel: viewModel)
                    } label: {
                        TransactionRow(transaction: transaction, viewModel: viewModel)
                    }
                }
                .onDelete(perform: deleteTransactions)
            }
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTransaction = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingFilters = true
                    } label: {
                        HStack {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                            Text(filterText)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView(viewModel: viewModel)
            }
            .actionSheet(isPresented: $showingFilters) {
                ActionSheet(
                    title: Text("Filtrer les transactions"),
                    buttons: [
                        .default(Text("Tout")) { selectedFilter = nil },
                        .default(Text("Dépenses")) { selectedFilter = .expense },
                        .default(Text("Revenus")) { selectedFilter = .income },
                        .cancel(Text("Annuler"))
                    ]
                )
            }
        }
    }
    
    private var filterText: String {
        switch selectedFilter {
        case .expense: return "Dépenses"
        case .income: return "Revenus"
        case nil: return "Tout"
        }
    }
    
    private var filteredTransactions: [Transaction] {
        guard let filter = selectedFilter else { return viewModel.transactions }
        return viewModel.transactions.filter { $0.type == filter }
    }
    
    private func deleteTransactions(at offsets: IndexSet) {
        viewModel.deleteTransaction(at: offsets)
    }
} 
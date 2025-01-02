import SwiftUI

struct TransactionListView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @State private var selectedFilter: TransactionType?
    
    var body: some View {
        List {
            ForEach(filteredTransactions) { transaction in
                TransactionRow(transaction: transaction, viewModel: viewModel)
            }
            .onDelete(perform: viewModel.deleteTransaction)
        }
        .navigationTitle("Transactions")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Toutes") { selectedFilter = nil }
                    Button("Dépenses") { selectedFilter = .expense }
                    Button("Revenus") { selectedFilter = .income }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
    }
    
    private var filteredTransactions: [Transaction] {
        viewModel.filteredTransactions(type: selectedFilter)
    }
} 
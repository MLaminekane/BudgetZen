import SwiftUI

struct TransactionDetailView: View {
    let transaction: Transaction
    @ObservedObject var viewModel: TransactionViewModel
    
    var body: some View {
        List {
            Section("Détails") {
                HStack {
                    Text("Montant")
                    Spacer()
                    Text(String(format: "%.2f €", transaction.amount))
                        .foregroundColor(transaction.type == .expense ? .red : .green)
                }
                
                HStack {
                    Text("Type")
                    Spacer()
                    Text(transaction.type.rawValue)
                }
                
                HStack {
                    Text("Date")
                    Spacer()
                    Text(transaction.date.formatted(date: .long, time: .shortened))
                }
                
                if let category = viewModel.categories.first(where: { $0.id == transaction.categoryId }) {
                    HStack {
                        Text("Catégorie")
                        Spacer()
                        Image(systemName: category.icon)
                            .foregroundColor(Color(hex: category.color))
                        Text(category.name)
                    }
                }
                
                if let note = transaction.note {
                    HStack {
                        Text("Note")
                        Spacer()
                        Text(note)
                    }
                }
            }
            
            if transaction.isRecurring {
                Section("Récurrence") {
                    HStack {
                        Text("Intervalle")
                        Spacer()
                        Text(transaction.recurringInterval?.rawValue ?? "")
                    }
                }
            }
        }
        .navigationTitle(transaction.title)
        .navigationBarTitleDisplayMode(.inline)
    }
} 
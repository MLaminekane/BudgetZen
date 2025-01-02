import SwiftUI

struct BudgetFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TransactionViewModel
    @State private var limit: Double
    @State private var period: Budget.Period
    
    let budget: Budget
    
    init(viewModel: TransactionViewModel, budget: Budget) {
        self.viewModel = viewModel
        self.budget = budget
        _limit = State(initialValue: budget.limit)
        _period = State(initialValue: budget.period)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Budget")) {
                    HStack {
                        Text("Catégorie")
                        Spacer()
                        Text(budget.category.name)
                            .foregroundColor(.secondary)
                    }
                    
                    TextField("Limite", value: $limit, format: .currency(code: "EUR"))
                        .keyboardType(.decimalPad)
                    
                    Picker("Période", selection: $period) {
                        Text("Semaine").tag(Budget.Period.week)
                        Text("Mois").tag(Budget.Period.month)
                        Text("Année").tag(Budget.Period.year)
                    }
                }
            }
            .navigationTitle("Modifier le budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
                        saveBudget()
                    }
                }
            }
        }
    }
    
    private func saveBudget() {
        let updatedBudget = Budget(
            id: budget.id,
            category: budget.category,
            limit: limit,
            period: period
        )
        viewModel.updateBudget(updatedBudget)
        dismiss()
    }
} 
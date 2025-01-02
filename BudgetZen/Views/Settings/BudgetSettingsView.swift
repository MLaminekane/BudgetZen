import SwiftUI

struct BudgetSettingsView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @State private var editingBudget: Budget?
    
    var body: some View {
        List {
            ForEach(viewModel.budgets) { budget in
                BudgetRow(budget: budget)
                    .onTapGesture {
                        editingBudget = budget
                    }
            }
        }
        .navigationTitle("Budgets")
        .sheet(item: $editingBudget) { budget in
            BudgetFormView(viewModel: viewModel, budget: budget)
        }
    }
}

struct BudgetRow: View {
    let budget: Budget
    
    var body: some View {
        HStack {
            Image(systemName: budget.category.icon)
                .foregroundColor(Color(hex: budget.category.color))
            
            VStack(alignment: .leading) {
                Text(budget.category.name)
                Text("\(String(format: "%.2f €", budget.limit)) / \(budget.period.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
} 
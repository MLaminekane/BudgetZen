import SwiftUI

struct BudgetProgressRow: View {
    let budget: Budget
    let spent: Double
    
    private var progress: Double {
        min(spent / budget.limit, 1.0)
    }
    
    private var remainingAmount: Double {
        budget.limit - spent
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: budget.category.icon)
                    .foregroundColor(Color(hex: budget.category.color))
                Text(budget.category.name)
                Spacer()
                Text(String(format: "%.0f%%", progress * 100))
                    .foregroundColor(progress > 0.9 ? .red : .secondary)
            }
            
            ProgressView(value: progress)
                .tint(progress > 0.9 ? .red : .blue)
            
            HStack {
                Text(String(format: "%.2f € / %.2f €", spent, budget.limit))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Reste: \(String(format: "%.2f €", remainingAmount))")
                    .font(.caption)
                    .foregroundColor(remainingAmount < 0 ? .red : .secondary)
            }
        }
    }
} 
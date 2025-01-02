import SwiftUI

struct SubscriptionRow: View {
    let transaction: Transaction
    @ObservedObject var viewModel: TransactionViewModel
    
    private var category: Category? {
        viewModel.categories.first(where: { $0.id == transaction.categoryId })
    }
    
    var body: some View {
        HStack {
            if let category = category {
                Image(systemName: category.icon)
                    .foregroundColor(Color(hex: category.color))
            }
            
            VStack(alignment: .leading) {
                Text(transaction.title)
                    .font(.subheadline)
                Text(transaction.recurringInterval?.rawValue ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(String(format: "%.2f €", transaction.amount))
                .foregroundColor(transaction.amount < 0 ? .red : .green)
        }
        .padding(.vertical, 4)
    }
} 
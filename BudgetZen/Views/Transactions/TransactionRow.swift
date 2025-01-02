import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction
    @ObservedObject var viewModel: TransactionViewModel
    
    var body: some View {
        HStack {
            if let category = viewModel.categories.first(where: { $0.id == transaction.categoryId }) {
                Image(systemName: category.icon)
                    .foregroundColor(Color(hex: category.color))
                    .frame(width: 40, height: 40)
                    .background(Color(hex: category.color).opacity(0.2))
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading) {
                Text(transaction.title)
                    .font(.headline)
                Text(transaction.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(String(format: "%.2f €", transaction.amount))
                .foregroundColor(transaction.type == .expense ? .red : .green)
                .font(.headline)
        }
        .padding(.vertical, 4)
    }
} 
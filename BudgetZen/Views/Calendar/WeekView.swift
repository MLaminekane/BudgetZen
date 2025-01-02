import SwiftUI

struct WeekView: View {
    @ObservedObject var viewModel: TransactionViewModel
    let week: Date
    let selectedDate: Date
    let onDateSelected: (Date) -> Void
    
    private let calendar = Calendar.current
    private let weekDays = ["Dim", "Lun", "Mar", "Mer", "Jeu", "Ven", "Sam"]
    
    var body: some View {
        VStack(spacing: 0) {
            // En-tête des jours
            HStack {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 8)
            
            // Jours de la semaine
            VStack(spacing: 1) {
                ForEach(daysInWeek(), id: \.self) { date in
                    WeekDayRow(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        viewModel: viewModel
                    )
                    .onTapGesture {
                        withAnimation {
                            onDateSelected(date)
                        }
                    }
                }
            }
            
            // Liste des transactions
            List {
                ForEach(transactionsForSelectedDate()) { transaction in
                    TransactionRow(transaction: transaction, viewModel: viewModel)
                }
            }
        }
    }
    
    private func daysInWeek() -> [Date] {
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: week))!
        return (0..<7).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: startOfWeek)
        }
    }
    
    private func transactionsForSelectedDate() -> [Transaction] {
        viewModel.transactions.filter { transaction in
            calendar.isDate(transaction.date, inSameDayAs: selectedDate)
        }
    }
}

struct WeekDayRow: View {
    let date: Date
    let isSelected: Bool
    @ObservedObject var viewModel: TransactionViewModel
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(dayHeader)
                    .font(.headline)
                Spacer()
                if let total = calculateDayTotal() {
                    Text(String(format: "%.2f €", total))
                        .font(.subheadline)
                        .foregroundColor(total >= 0 ? .green : .red)
                }
            }
            
            let transactions = transactionsForDay()
            if !transactions.isEmpty {
                ForEach(transactions) { transaction in
                    TransactionRow(transaction: transaction, viewModel: viewModel)
                }
            } else {
                Text("Aucune transaction")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.vertical, 4)
            }
        }
        .padding()
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color(.systemBackground))
    }
    
    private var dayHeader: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d MMMM"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
    
    private func transactionsForDay() -> [Transaction] {
        viewModel.transactions.filter { transaction in
            calendar.isDate(transaction.date, inSameDayAs: date)
        }
    }
    
    private func calculateDayTotal() -> Double? {
        let transactions = transactionsForDay()
        if transactions.isEmpty { return nil }
        
        return transactions.reduce(0) { total, transaction in
            total + (transaction.type == .income ? transaction.amount : -transaction.amount)
        }
    }
} 
import SwiftUI

struct MonthView: View {
    let month: Date
    let selectedDate: Date
    let onDateSelected: (Date) -> Void
    @ObservedObject var viewModel: TransactionViewModel
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["Dim", "Lun", "Mar", "Mer", "Jeu", "Ven", "Sam"]
    
    var body: some View {
        VStack(spacing: 8) {
            // En-tête des jours de la semaine
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Grille des jours
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(Array(daysInMonth().enumerated()), id: \.offset) { index, date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            hasTransactions: hasTransactions(on: date)
                        )
                        .onTapGesture {
                            onDateSelected(date)
                        }
                    } else {
                        Color.clear
                            .aspectRatio(1, contentMode: .fill)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func daysInMonth() -> [Date?] {
        let interval = calendar.dateInterval(of: .month, for: month)!
        let firstDay = interval.start
        
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let daysInMonth = calendar.range(of: .day, in: .month, for: month)!.count
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        
        // Ajouter des cellules vides à la fin si nécessaire
        let totalDays = days.count
        let remainingDays = 42 - totalDays // 6 semaines * 7 jours
        if remainingDays > 0 {
            days.append(contentsOf: Array(repeating: nil as Date?, count: remainingDays))
        }
        
        return days
    }
    
    private func hasTransactions(on date: Date) -> Bool {
        let calendar = Calendar.current
        return viewModel.transactions.contains { transaction in
            calendar.isDate(transaction.date, inSameDayAs: date)
        }
    }
}

#Preview {
    MonthView(
        month: Date(),
        selectedDate: Date(),
        onDateSelected: { _ in },
        viewModel: TransactionViewModel()
    )
} 
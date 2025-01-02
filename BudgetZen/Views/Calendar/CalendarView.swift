import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @State private var selectedDate = Date()
    @State private var showingDatePicker = false
    
    var body: some View {
        NavigationView {
            VStack {
                // En-tête du calendrier
                HStack {
                    Button {
                        showingDatePicker = true
                    } label: {
                        HStack {
                            Text(selectedDate.formatted(.dateTime.month(.wide).year()))
                                .font(.title2.bold())
                            Image(systemName: "chevron.down")
                        }
                    }
                    Spacer()
                }
                .padding()
                
                // Grille du calendrier
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                    // En-têtes des jours
                    ForEach(["Dim", "Lun", "Mar", "Mer", "Jeu", "Ven", "Sam"], id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Jours du mois
                    ForEach(Array(daysInMonth().enumerated()), id: \.offset) { index, date in
                        if let date = date {
                            DayCell(
                                date: date,
                                isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                                hasTransactions: hasTransactions(on: date)
                            )
                            .onTapGesture {
                                selectedDate = date
                            }
                        } else {
                            Color.clear
                        }
                    }
                }
                .padding()
                
                // Transactions du jour sélectionné
                List {
                    ForEach(transactionsForSelectedDate()) { transaction in
                        TransactionRow(transaction: transaction, viewModel: viewModel)
                    }
                }
            }
            .navigationTitle("Calendrier")
            .sheet(isPresented: $showingDatePicker) {
                DatePicker(
                    "Sélectionner une date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .presentationDetents([.medium])
            }
        }
    }
    
    private func daysInMonth() -> [Date?] {
        let calendar = Calendar.current
        let interval = calendar.dateInterval(of: .month, for: selectedDate)!
        let firstDay = interval.start
        
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedDate)!.count
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func hasTransactions(on date: Date) -> Bool {
        let calendar = Calendar.current
        return viewModel.transactions.contains { transaction in
            calendar.isDate(transaction.date, inSameDayAs: date)
        }
    }
    
    private func transactionsForSelectedDate() -> [Transaction] {
        let calendar = Calendar.current
        return viewModel.transactions.filter { transaction in
            calendar.isDate(transaction.date, inSameDayAs: selectedDate)
        }
    }
} 
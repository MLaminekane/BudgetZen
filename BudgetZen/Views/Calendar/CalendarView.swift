import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @State private var selectedDate = Date()
    @State private var showingDatePicker = false
    @State private var showingAddTransaction = false
    @State private var showingFilters = false
    @State private var selectedFilter: TransactionType?
    @State private var selectedTransaction: Transaction?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
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
                    
                    // Boutons de filtres et d'ajout
                    HStack(spacing: 12) {
                        Menu {
                            Button("Toutes") { selectedFilter = nil }
                            Button("Dépenses") { selectedFilter = .expense }
                            Button("Revenus") { selectedFilter = .income }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.title2)
                        }
                        
                        Button {
                            showingAddTransaction = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                    }
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
                
                // Résumé des transactions du jour
                if !transactionsForSelectedDate().isEmpty {
                    TransactionSummaryView(transactions: transactionsForSelectedDate())
                        .padding()
                }
                
                // Liste des transactions
                List {
                    ForEach(filteredTransactions) { transaction in
                        TransactionRow(transaction: transaction, viewModel: viewModel)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedTransaction = transaction
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    if let index = viewModel.transactions.firstIndex(where: { $0.id == transaction.id }) {
                                        viewModel.deleteTransaction(at: IndexSet([index]))
                                    }
                                } label: {
                                    Label("Supprimer", systemImage: "trash")
                                }
                            }
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
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView(viewModel: viewModel, preselectedDate: selectedDate)
            }
            .sheet(item: $selectedTransaction) { transaction in
                TransactionDetailSheet(transaction: transaction, viewModel: viewModel)
            }
        }
    }
    
    private var filteredTransactions: [Transaction] {
        let dayTransactions = transactionsForSelectedDate()
        guard let filter = selectedFilter else { return dayTransactions }
        return dayTransactions.filter { $0.type == filter }
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
    
    private func deleteTransactions(at offsets: IndexSet) {
        let transactionsToDelete = transactionsForSelectedDate()
        offsets.forEach { index in
            if let transactionIndex = viewModel.transactions.firstIndex(where: { $0.id == transactionsToDelete[index].id }) {
                viewModel.deleteTransaction(at: IndexSet([transactionIndex]))
            }
        }
    }
}

// Vue de résumé des transactions
struct TransactionSummaryView: View {
    let transactions: [Transaction]
    
    private var totalExpenses: Double {
        transactions.filter { $0.amount < 0 }.reduce(0) { $0 + abs($1.amount) }
    }
    
    private var totalIncome: Double {
        transactions.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Dépenses")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.2f €", totalExpenses))
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Revenus")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.2f €", totalIncome))
                        .foregroundColor(.green)
                }
            }
            
            Divider()
            
            HStack {
                Text("Solde du jour")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: "%.2f €", totalIncome - totalExpenses))
                    .foregroundColor(totalIncome - totalExpenses >= 0 ? .green : .red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// Nouvelle vue pour les détails de la transaction
struct TransactionDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let transaction: Transaction
    let viewModel: TransactionViewModel
    
    private var category: Category? {
        viewModel.category(for: transaction.categoryId)
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        if let category = category {
                            Image(systemName: category.icon)
                                .foregroundColor(category.uiColor)
                        }
                        Text(transaction.title)
                            .font(.headline)
                        Spacer()
                        Text(String(format: "%.2f €", transaction.amount))
                            .foregroundColor(transaction.amount >= 0 ? .green : .red)
                    }
                }
                
                Section(header: Text("Détails")) {
                    LabeledContent("Date", value: transaction.date.formatted(date: .long, time: .omitted))
                    
                    if let category = category {
                        LabeledContent("Catégorie", value: category.name)
                    }
                    
                    LabeledContent("Type", value: transaction.type.rawValue)
                    
                    if let note = transaction.note {
                        LabeledContent("Note", value: note)
                    }
                }
                
                if transaction.isRecurring {
                    Section(header: Text("Récurrence")) {
                        LabeledContent("Intervalle", value: transaction.recurringInterval?.rawValue ?? "Non défini")
                    }
                }
            }
            .navigationTitle("Détails")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
} 
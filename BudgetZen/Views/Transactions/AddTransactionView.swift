import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TransactionViewModel
    @State private var title = ""
    @State private var amount = 0.0
    @State private var type: TransactionType = .expense
    @State private var selectedCategory: Category?
    @State private var date: Date
    @State private var note = ""
    @State private var isRecurring = false
    @State private var recurringInterval: RecurringInterval?
    
    init(viewModel: TransactionViewModel, preselectedDate: Date? = nil) {
        self.viewModel = viewModel
        _date = State(initialValue: preselectedDate ?? Date())
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informations")) {
                    TextField("Titre", text: $title)
                    
                    TextField("Montant", value: $amount, format: .currency(code: "EUR"))
                        .keyboardType(.decimalPad)
                    
                    TextField("Note", text: $note)
                    
                    DatePicker("Date", selection: $date, displayedComponents: [.date])
                }
                
                Section(header: Text("Type")) {
                    Picker("Type", selection: $type) {
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Catégorie")) {
                    let categories = type == .expense ? viewModel.expenseCategories : viewModel.incomeCategories
                    
                    if categories.isEmpty {
                        NavigationLink(destination: CategoriesSettingsView(viewModel: viewModel)) {
                            Text("Ajouter une catégorie")
                                .foregroundColor(.blue)
                        }
                    } else {
                        ForEach(categories) { category in
                            CategorySelectionRow(
                                category: category,
                                isSelected: selectedCategory?.id == category.id,
                                action: { selectedCategory = category }
                            )
                        }
                        
                        NavigationLink(destination: CategoriesSettingsView(viewModel: viewModel)) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Gérer les catégories")
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
                
                Section {
                    Toggle("Transaction récurrente", isOn: $isRecurring)
                    
                    if isRecurring {
                        Picker("Intervalle", selection: $recurringInterval) {
                            ForEach(RecurringInterval.allCases, id: \.self) { interval in
                                Text(interval.rawValue).tag(interval)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Nouvelle transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ajouter") {
                        saveTransaction()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private var isValid: Bool {
        !title.isEmpty && amount > 0 && selectedCategory != nil
    }
    
    private func saveTransaction() {
        guard let category = selectedCategory else { return }
        
        let transaction = Transaction(
            amount: type == .expense ? -amount : amount,
            title: title,
            date: date,
            type: type,
            categoryId: category.id,
            note: note.isEmpty ? nil : note,
            isRecurring: isRecurring,
            recurringInterval: isRecurring ? recurringInterval : nil
        )
        
        viewModel.addTransaction(transaction)
        dismiss()
    }
}

struct CategorySelectionRow: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: category.icon)
                    .foregroundColor(category.uiColor)
                    .frame(width: 30)
                
                Text(category.name)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
        }
        .foregroundColor(.primary)
    }
} 

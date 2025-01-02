import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TransactionViewModel
    
    @State private var title = ""
    @State private var amount = ""
    @State private var description = ""
    @State private var date = Date()
    @State private var type: TransactionType = .expense
    @State private var selectedCategoryId: UUID?
    @State private var isRecurring = false
    @State private var recurringInterval: RecurringInterval = .monthly
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Détails")) {
                    TextField("Titre", text: $title)
                    
                    TextField("Montant", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    TextField("Description (optionnel)", text: $description)
                    
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section(header: Text("Type")) {
                    Picker("Type", selection: $type) {
                        Text(TransactionType.expense.rawValue).tag(TransactionType.expense)
                        Text(TransactionType.income.rawValue).tag(TransactionType.income)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Catégorie")) {
                    ForEach(viewModel.categories.filter { $0.type == type }) { category in
                        HStack {
                            Image(systemName: category.icon)
                                .foregroundColor(category.uiColor)
                            Text(category.name)
                            Spacer()
                            if selectedCategoryId == category.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedCategoryId = category.id
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
        !title.isEmpty && !amount.isEmpty && selectedCategoryId != nil
    }
    
    private func saveTransaction() {
        guard let amount = Double(amount.replacingOccurrences(of: ",", with: ".")),
              let categoryId = selectedCategoryId else { return }
        
        let transaction = Transaction(
            amount: amount,
            title: title,
            date: date,
            type: type,
            categoryId: selectedCategoryId ?? UUID(),
            note: description.isEmpty ? nil : description,
            isRecurring: isRecurring,
            recurringInterval: isRecurring ? recurringInterval : nil
        )
        
        viewModel.addTransaction(transaction)
        dismiss()
    }
} 

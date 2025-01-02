import SwiftUI

struct CategoriesSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TransactionViewModel
    @State private var showingAddCategory = false
    @State private var editingCategory: Category?
    
    var body: some View {
        List {
            Section(header: Text("Dépenses")) {
                ForEach(viewModel.expenseCategories) { category in
                    CategoryRow(category: category)
                        .onTapGesture {
                            editingCategory = category
                        }
                }
            }
            
            Section(header: Text("Revenus")) {
                ForEach(viewModel.incomeCategories) { category in
                    CategoryRow(category: category)
                        .onTapGesture {
                            editingCategory = category
                        }
                }
            }
        }
        .navigationTitle("Catégories")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddCategory = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            CategoryFormView(viewModel: viewModel)
        }
        .sheet(item: $editingCategory) { category in
            CategoryFormView(viewModel: viewModel, category: category)
        }
    }
}

struct CategoryRow: View {
    let category: Category
    
    var body: some View {
        HStack {
            Image(systemName: category.icon)
                .foregroundColor(category.uiColor)
                .frame(width: 30)
            
            Text(category.name)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
    }
}

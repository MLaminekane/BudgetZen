import SwiftUI

struct CategoriesSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var showingAddCategory = false
    @State private var selectedType = TransactionType.expense
    
    var body: some View {
        List {
            CategorySection(type: .expense, viewModel: viewModel)
            CategorySection(type: .income, viewModel: viewModel)
        }
        .navigationTitle("Catégories")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                AddButton(showingAddCategory: $showingAddCategory)
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            CategoryFormView(viewModel: viewModel, editingCategory: nil)
        }
        .sheet(item: $viewModel.editingCategory) { category in
            CategoryFormView(viewModel: viewModel, editingCategory: category)
        }
    }
}

struct CategorySection: View {
    let type: TransactionType
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        Section(header: Text(type.rawValue)) {
            ForEach(viewModel.categories.filter { $0.type == type }) { category in
                CategoryRow(category: category, viewModel: viewModel)
            }
            .onMove { source, destination in
                viewModel.moveCategory(from: source, to: destination, type: type)
            }
            .onDelete { indexSet in
                viewModel.deleteCategories(at: indexSet, type: type)
            }
        }
    }
}

struct CategoryRow: View {
    let category: Category
    let viewModel: SettingsViewModel
    
    var body: some View {
        Button(action: {
            viewModel.editingCategory = category
        }) {
            HStack {
                Image(systemName: category.icon)
                    .foregroundColor(category.uiColor)
                Text(category.name)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
    }
}

struct AddButton: View {
    @Binding var showingAddCategory: Bool
    
    var body: some View {
        Button(action: { showingAddCategory = true }) {
            Image(systemName: "plus")
        }
    }
} 
import SwiftUI

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Types de transactions")) {
                    ForEach(TransactionType.allCases, id: \.self) { type in
                        Toggle(type.rawValue, isOn: Binding(
                            get: { viewModel.selectedTypes.contains(type) },
                            set: { isSelected in
                                if isSelected {
                                    viewModel.selectedTypes.insert(type)
                                } else {
                                    viewModel.selectedTypes.remove(type)
                                }
                            }
                        ))
                    }
                }
                
                Section(header: Text("Catégories")) {
                    Button("Tout sélectionner") {
                        let categoryIds = Set(viewModel.categories.map { $0.id })
                        viewModel.selectedCategories = categoryIds
                    }
                    
                    Button("Tout désélectionner") {
                        viewModel.selectedCategories.removeAll()
                    }
                    
                    ForEach(viewModel.categories) { category in
                        Toggle(isOn: Binding(
                            get: { viewModel.selectedCategories.contains(category.id) },
                            set: { isSelected in
                                if isSelected {
                                    viewModel.selectedCategories.insert(category.id)
                                } else {
                                    viewModel.selectedCategories.remove(category.id)
                                }
                            }
                        )) {
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.uiColor)
                                Text(category.name)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filtres")
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
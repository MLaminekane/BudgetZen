import SwiftUI

struct ExportView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TransactionViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button("Exporter en CSV") {
                        viewModel.exportData(format: .csv)
                        dismiss()
                    }
                    
                    Button("Exporter en PDF") {
                        viewModel.exportData(format: .pdf)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Exporter")
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

#Preview {
    ExportView(viewModel: TransactionViewModel())
} 
import SwiftUI

struct NotificationSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        List {
            if viewModel.enableReminders {
                Section(header: Text("Rappels de saisie")) {
                    DatePicker("Heure du rappel", selection: $viewModel.reminderTime, displayedComponents: .hourAndMinute)
                    
                    Picker("Fréquence", selection: $viewModel.reminderFrequency) {
                        Text("Quotidien").tag(NotificationFrequency.daily)
                        Text("Hebdomadaire").tag(NotificationFrequency.weekly)
                        Text("Mensuel").tag(NotificationFrequency.monthly)
                    }
                }
            }
            
            if viewModel.enableBudgetAlerts {
                Section(header: Text("Alertes de budget")) {
                    Toggle("Alerte de dépassement", isOn: $viewModel.alertOnOverspend)
                    
                    Stepper(
                        "Seuil d'alerte: \(Int(viewModel.budgetAlertThreshold))%",
                        value: $viewModel.budgetAlertThreshold,
                        in: 50...100
                    )
                }
            }
        }
        .navigationTitle("Notifications")
        .onDisappear {
            viewModel.updateNotificationSettings()
        }
    }
} 
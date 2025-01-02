import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @AppStorage("notifyLowBalance") private var notifyLowBalance = false
    @AppStorage("notifyBudgetExceeded") private var notifyBudgetExceeded = true
    @AppStorage("notifyRecurringTransactions") private var notifyRecurringTransactions = true
    @AppStorage("lowBalanceThreshold") private var lowBalanceThreshold = 100.0
    @AppStorage("notifyTime") private var notifyTime = Date()
    @AppStorage("weeklyReportEnabled") private var weeklyReportEnabled = false
    @State private var showingPermissionAlert = false
    @State private var notificationsAuthorized = false
    
    var body: some View {
        List {
            Section {
                // État des notifications
                Button(action: {
                    if notificationsAuthorized {
                        // Ouvrir les paramètres de l'app
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } else {
                        requestNotificationPermission()
                    }
                }) {
                    HStack {
                        Image(systemName: notificationsAuthorized ? "bell.fill" : "bell.slash.fill")
                            .foregroundColor(notificationsAuthorized ? .green : .red)
                        Text("État des notifications")
                        Spacer()
                        Text(notificationsAuthorized ? "Activées" : "Désactivées")
                            .foregroundColor(.secondary)
                        if !notificationsAuthorized {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            
            Section(header: Text("Alertes")) {
                // Solde bas
                Toggle(isOn: $notifyLowBalance) {
                    Label("Solde bas", systemImage: "exclamationmark.circle")
                }
                
                if notifyLowBalance {
                    HStack {
                        Text("Seuil d'alerte")
                        Spacer()
                        TextField("Montant", value: $lowBalanceThreshold, format: .currency(code: "EUR"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                // Budget dépassé
                Toggle(isOn: $notifyBudgetExceeded) {
                    Label("Budget dépassé", systemImage: "chart.line.uptrend.xyaxis")
                }
                
                // Transactions récurrentes
                Toggle(isOn: $notifyRecurringTransactions) {
                    Label("Transactions récurrentes", systemImage: "repeat")
                }
            }
            
            Section(header: Text("Rapports")) {
                // Rapport hebdomadaire
                Toggle(isOn: $weeklyReportEnabled) {
                    Label("Rapport hebdomadaire", systemImage: "doc.text.fill")
                }
                
                if weeklyReportEnabled {
                    DatePicker("Heure de notification",
                             selection: $notifyTime,
                             displayedComponents: .hourAndMinute)
                }
            }
            
            if !notificationsAuthorized {
                Section {
                    Button(action: {
                        requestNotificationPermission()
                    }) {
                        HStack {
                            Image(systemName: "bell.badge")
                            Text("Activer les notifications")
                        }
                    }
                }
            }
        }
        .navigationTitle("Notifications")
        .onAppear {
            checkNotificationStatus()
        }
        .onChange(of: notificationsAuthorized) { oldValue, newValue in
            if newValue {
                // Programmer les notifications quand elles sont activées
                scheduleNotifications()
            }
        }
        .onChange(of: notifyLowBalance) { oldValue, newValue in
            if newValue {
                scheduleNotifications()
            }
        }
        .onChange(of: notifyTime) { _, _ in
            if weeklyReportEnabled {
                scheduleWeeklyReport()
            }
        }
        .alert("Notifications désactivées", isPresented: $showingPermissionAlert) {
            Button("Paramètres", role: .none) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Activez les notifications dans les paramètres pour recevoir des alertes importantes.")
        }
    }
    
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationsAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                notificationsAuthorized = granted
                if granted {
                    // Si l'autorisation est accordée, programmer les notifications
                    scheduleNotifications()
                } else {
                    showingPermissionAlert = true
                }
            }
        }
    }
    
    private func scheduleNotifications() {
        guard notificationsAuthorized else { return }
        
        // Configurer les notifications selon les préférences
        if notifyLowBalance {
            scheduleLowBalanceNotification()
        }
        
        if weeklyReportEnabled {
            scheduleWeeklyReport()
        }
    }
    
    private func scheduleLowBalanceNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Solde bas"
        content.body = "Votre solde est passé sous \(lowBalanceThreshold)€"
        content.sound = .default
        
        // Créer un trigger pour vérifier quotidiennement
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 86400, repeats: true)
        let request = UNNotificationRequest(identifier: "lowBalance", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func scheduleWeeklyReport() {
        let content = UNMutableNotificationContent()
        content.title = "Rapport hebdomadaire"
        content.body = "Votre résumé financier de la semaine est disponible"
        content.sound = .default
        
        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: notifyTime)
        dateComponents.weekday = 1 // Dimanche
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "weeklyReport", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

#Preview {
    NotificationSettingsView()
} 
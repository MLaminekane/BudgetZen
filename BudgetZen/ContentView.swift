//
//  ContentView.swift
//  BudgetZen
//
//  Created by Lamine  on 2025-01-01.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var transactionViewModel = TransactionViewModel()
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        TabView {
            DashboardView(viewModel: transactionViewModel)
                .tabItem {
                    Label("Tableau bord", systemImage: "chart.pie.fill")
                }
            
            CalendarView(viewModel: transactionViewModel)
                .tabItem {
                    Label("Calendrier", systemImage: "calendar")
                }
            
            StatisticsView(transactionViewModel: transactionViewModel)
                .tabItem {
                    Label("Graphiques", systemImage: "chart.bar.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Réglages", systemImage: "gear")
                }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#Preview {
    ContentView()
}

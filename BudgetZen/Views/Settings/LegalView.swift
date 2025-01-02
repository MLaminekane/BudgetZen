import SwiftUI

struct LegalView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Mentions légales")
                    .font(.title)
                    .padding(.bottom)
                
                Group {
                    Text("Éditeur de l'application")
                        .font(.headline)
                    Text("BudgetZen est développée et éditée par [Votre nom].")
                    
                    Text("Contact")
                        .font(.headline)
                    Text("Email : contact@budgetzen.com")
                    
                    Text("Hébergement")
                        .font(.headline)
                    Text("L'application est hébergée par Apple Inc. via l'App Store.")
                }
                
                Divider()
                
                Text("Conditions d'utilisation")
                    .font(.headline)
                Text("En utilisant cette application, vous acceptez les conditions d'utilisation décrites ci-dessous...")
            }
            .padding()
        }
        .navigationTitle("Mentions légales")
    }
} 
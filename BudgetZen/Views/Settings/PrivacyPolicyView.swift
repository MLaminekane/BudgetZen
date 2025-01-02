import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Politique de confidentialité")
                    .font(.title)
                    .padding(.bottom)
                
                Group {
                    Text("Collecte des données")
                        .font(.headline)
                    Text("BudgetZen collecte uniquement les données nécessaires à son fonctionnement...")
                    
                    Text("Utilisation des données")
                        .font(.headline)
                    Text("Vos données sont stockées localement sur votre appareil...")
                    
                    Text("Synchronisation iCloud")
                        .font(.headline)
                    Text("Si vous activez la synchronisation iCloud, vos données seront...")
                }
                
                Divider()
                
                Text("Vos droits")
                    .font(.headline)
                Text("Vous pouvez à tout moment exporter ou supprimer vos données...")
            }
            .padding()
        }
        .navigationTitle("Confidentialité")
    }
} 
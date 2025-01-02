import SwiftUI

struct LegalView: View {
    var body: some View {
        List {
            Section {
                Text("Conditions d'utilisation")
                    .font(.body)
                    .padding()
            }
        }
        .navigationTitle("Mentions légales")
    }
} 
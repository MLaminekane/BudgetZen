import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        List {
            Section {
                Text("Politique de confidentialité")
                    .font(.body)
                    .padding()
            }
        }
        .navigationTitle("Confidentialité")
    }
} 
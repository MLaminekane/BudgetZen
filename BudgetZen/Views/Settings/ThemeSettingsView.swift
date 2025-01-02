import SwiftUI

struct ThemeSettingsView: View {
    @AppStorage("accentColorHex") private var accentColorHex = "#007AFF"
    @AppStorage("interfaceStyle") private var interfaceStyle = InterfaceStyle.system.rawValue
    
    var body: some View {
        List {
            Section(header: Text("Couleur principale")) {
                ColorPicker("Couleur", selection: Binding(
                    get: { Color(hex: accentColorHex) ?? .blue },
                    set: { accentColorHex = $0.toHex() }
                ))
            }
            
            Section(header: Text("Style")) {
                Picker("Style d'interface", selection: $interfaceStyle) {
                    Text("Système").tag(InterfaceStyle.system.rawValue)
                    Text("Clair").tag(InterfaceStyle.light.rawValue)
                    Text("Sombre").tag(InterfaceStyle.dark.rawValue)
                }
            }
        }
        .navigationTitle("Thème")
    }
}

#Preview {
    ThemeSettingsView()
} 
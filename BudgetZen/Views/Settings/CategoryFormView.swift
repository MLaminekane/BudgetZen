import SwiftUI

struct CategoryFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SettingsViewModel
    @State private var name = ""
    @State private var icon = "tag.fill"
    @State private var color = Color.blue
    @State private var type = TransactionType.expense
    @State private var showingError = false
    @State private var errorMessage = ""
    
    let editingCategory: Category?
    
    init(viewModel: SettingsViewModel, editingCategory: Category? = nil) {
        self.viewModel = viewModel
        self.editingCategory = editingCategory
        
        if let category = editingCategory {
            _name = State(initialValue: category.name)
            _icon = State(initialValue: category.icon)
            _color = State(initialValue: Color(hex: category.color))
            _type = State(initialValue: category.type)
        }
    }
    
    // Groupes d'icônes organisés par thème
    private let iconGroups: [(String, [String])] = [
        ("Finance", [
            "dollarsign.circle.fill", "creditcard.fill", "banknote.fill", 
            "wallet.pass.fill", "chart.pie.fill", "percent"
        ]),
        ("Transport", [
            "car.fill", "bus.fill", "tram.fill", "airplane", 
            "bicycle", "figure.walk"
        ]),
        ("Maison", [
            "house.fill", "bed.double.fill", "tv.fill", 
            "washer.fill", "lightbulb.fill"
        ]),
        ("Alimentation", [
            "cart.fill", "fork.knife", "cup.and.saucer.fill", 
            "wineglass.fill", "takeoutbag.and.cup.and.straw.fill"
        ]),
        ("Loisirs", [
            "gamecontroller.fill", "theatermasks.fill", "ticket.fill",
            "film.fill", "book.fill", "sportscourt.fill"
        ])
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informations")) {
                    TextField("Nom", text: $name)
                        .autocapitalization(.words)
                    
                    Picker("Type", selection: $type) {
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                Section(header: Text("Icône")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(iconGroups, id: \.0) { group in
                                VStack(alignment: .leading) {
                                    Text(group.0)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    LazyVGrid(columns: [
                                        GridItem(.adaptive(minimum: 44))
                                    ], spacing: 10) {
                                        ForEach(group.1, id: \.self) { iconName in
                                            IconButton(
                                                iconName: iconName,
                                                isSelected: icon == iconName,
                                                color: color
                                            ) {
                                                icon = iconName
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section(header: Text("Couleur")) {
                    ColorPicker("Couleur de la catégorie", selection: $color)
                    
                    // Palette de couleurs prédéfinies
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(predefinedColors, id: \.self) { presetColor in
                                Circle()
                                    .fill(presetColor)
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                                    )
                                    .onTapGesture {
                                        color = presetColor
                                    }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle(editingCategory == nil ? "Nouvelle catégorie" : "Modifier la catégorie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(editingCategory == nil ? "Ajouter" : "Enregistrer") {
                        saveCategory()
                    }
                    .disabled(!isValid)
                }
            }
            .alert("Erreur", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private let predefinedColors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple,
        .pink, .indigo, .teal, .mint, .cyan
    ]
    
    private func saveCategory() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validation
        guard !trimmedName.isEmpty else {
            errorMessage = "Le nom de la catégorie ne peut pas être vide"
            showingError = true
            return
        }
        
        // Vérifier si le nom existe déjà
        if viewModel.categories.contains(where: { $0.name.lowercased() == name.lowercased() && $0.id != editingCategory?.id }) {
            showingError = true
            errorMessage = "Une catégorie avec ce nom existe déjà"
            return
        }
        
        let category = Category(
            id: editingCategory?.id ?? UUID(),
            name: trimmedName,
            icon: icon,
            color: color.toHex(),
            type: type,
            isDefault: false,
            order: editingCategory?.order ?? viewModel.nextCategoryOrder(for: type)
        )
        
        if editingCategory != nil {
            viewModel.updateCategory(category)
        } else {
            viewModel.addCategory(category)
        }
        
        dismiss()
    }
}

struct IconButton: View {
    let iconName: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.title2)
                .frame(width: 44, height: 44)
                .foregroundColor(isSelected ? .white : color)
                .background(isSelected ? color : Color.clear)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color, lineWidth: 1)
                )
        }
    }
} 
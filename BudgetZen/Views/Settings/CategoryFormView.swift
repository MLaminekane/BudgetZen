import SwiftUI

struct CategoryFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TransactionViewModel
    
    @State private var name: String
    @State private var icon: String
    @State private var selectedColor: Color
    @State private var type: TransactionType
    @State private var showingError = false
    @State private var errorMessage = ""
    
    private let category: Category?
    
    init(viewModel: TransactionViewModel, category: Category? = nil) {
        self.viewModel = viewModel
        self.category = category
        _name = State(initialValue: category?.name ?? "")
        _icon = State(initialValue: category?.icon ?? "tag")
        _selectedColor = State(initialValue: category?.uiColor ?? .blue)
        _type = State(initialValue: category?.type ?? .expense)
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
                                                color: selectedColor
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
                    ColorPicker("Couleur", selection: $selectedColor)
                    
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
                                        selectedColor = presetColor
                                    }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle(category == nil ? "Nouvelle catégorie" : "Modifier la catégorie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(category == nil ? "Ajouter" : "Enregistrer") {
                        save()
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
    
    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            errorMessage = "Le nom de la catégorie ne peut pas être vide"
            showingError = true
            return
        }
        
        if viewModel.categories.contains(where: { $0.name.lowercased() == trimmedName.lowercased() && $0.id != category?.id }) {
            showingError = true
            errorMessage = "Une catégorie avec ce nom existe déjà"
            return
        }
        
        let newOrder = category?.order ?? viewModel.categories.filter { $0.type == type }.count
        
        let newCategory = Category(
            id: category?.id ?? UUID(),
            name: trimmedName,
            icon: icon,
            color: selectedColor.toHex(),
            type: type,
            isDefault: category?.isDefault ?? false,
            order: newOrder
        )
        
        if let category = category {
            viewModel.updateCategory(newCategory)
        } else {
            viewModel.addCategory(newCategory)
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

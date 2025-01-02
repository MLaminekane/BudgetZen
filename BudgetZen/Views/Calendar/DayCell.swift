import SwiftUI

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let hasTransactions: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? Color.accentColor : Color.clear)
                .frame(width: 32, height: 32)
            
            Text("\(Calendar.current.component(.day, from: date))")
                .foregroundColor(isSelected ? .white : .primary)
            
            if hasTransactions {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 4, height: 4)
                    .offset(y: 12)
            }
        }
        .frame(height: 40)
    }
}

#Preview {
    DayCell(
        date: Date(),
        isSelected: true,
        hasTransactions: true
    )
    .padding()
} 

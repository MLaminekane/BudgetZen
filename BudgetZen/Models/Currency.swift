import Foundation

struct Currency: Identifiable {
    let id = UUID()
    let code: String
    let name: String
    let symbol: String
}

struct Language: Identifiable {
    let id = UUID()
    let code: String
    let name: String
} 
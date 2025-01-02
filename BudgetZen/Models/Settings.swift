import Foundation
import SwiftUI

enum InterfaceStyle: String, Codable {
    case system
    case light
    case dark
}

enum ExportFormat: String, Codable {
    case csv
    case pdf
}

extension Color: RawRepresentable {
    public init?(rawValue: String) {
        guard let color = Color(hex: rawValue) else {
            return nil
        }
        self = color
    }
    
    public var rawValue: String {
        self.toHex()
    }
} 
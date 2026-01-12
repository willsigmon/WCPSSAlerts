import SwiftUI

enum ColorTokens {
    // MARK: - Brand Colors
    static let primary = Color(hex: "1E40AF")      // WCPSS Blue
    static let secondary = Color(hex: "3B82F6")    // Light Blue
    static let accent = Color(hex: "F59E0B")       // Amber

    // MARK: - Status Colors
    static let success = Color(hex: "10B981")      // Green - Open
    static let warning = Color(hex: "F59E0B")      // Amber - Delay
    static let error = Color(hex: "EF4444")        // Red - Closed
    static let info = Color(hex: "3B82F6")         // Blue - Info

    // MARK: - Closure Status Colors
    static let statusOpen = success
    static let statusDelay = warning
    static let statusClosed = error
    static let statusRemote = Color(hex: "8B5CF6") // Purple - E-Learning

    // MARK: - Probability Gradient
    static func probabilityColor(_ probability: Int) -> Color {
        switch probability {
        case 0..<20: return success
        case 20..<40: return Color(hex: "84CC16") // Lime
        case 40..<60: return warning
        case 60..<80: return Color(hex: "F97316") // Orange
        default: return error
        }
    }

    // MARK: - Glass Effect
    static let glassBorder = Color.white.opacity(0.2)
    static let glassBackground = Color.white.opacity(0.05)

    // MARK: - Text
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textMuted = Color.gray

    // MARK: - Background
    static let backgroundPrimary = Color(.systemBackground)
    static let backgroundSecondary = Color(.secondarySystemBackground)
    static let backgroundTertiary = Color(.tertiarySystemBackground)
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

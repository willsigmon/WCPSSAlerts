import SwiftUI

enum SpacingTokens {
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

enum RadiusTokens {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let full: CGFloat = 9999
}

enum ShadowTokens {
    static let sm = Shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    static let md = Shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    static let lg = Shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    static let xl = Shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

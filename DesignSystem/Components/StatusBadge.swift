import SwiftUI

struct StatusBadge: View {
    let status: ClosureStatus
    let style: BadgeStyle

    enum BadgeStyle {
        case compact
        case full
        case pill
    }

    private var backgroundColor: Color {
        switch status {
        case .open: return ColorTokens.statusOpen
        case .delay2hr, .delay3hr: return ColorTokens.statusDelay
        case .closed: return ColorTokens.statusClosed
        case .eLearning: return ColorTokens.statusRemote
        case .earlyRelease: return ColorTokens.warning
        }
    }

    var body: some View {
        HStack(spacing: SpacingTokens.xxs) {
            Image(systemName: status.icon)
                .font(.system(size: style == .compact ? 12 : 14, weight: .semibold))

            if style != .compact {
                Text(status.displayName)
                    .font(style == .pill ? TypographyTokens.labelSmall : TypographyTokens.labelMedium)
                    .fontWeight(.semibold)
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, style == .compact ? SpacingTokens.xs : SpacingTokens.sm)
        .padding(.vertical, style == .compact ? SpacingTokens.xxs : SpacingTokens.xs)
        .background(backgroundColor)
        .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: SpacingTokens.md) {
        ForEach(ClosureStatus.allCases, id: \.self) { status in
            HStack(spacing: SpacingTokens.md) {
                StatusBadge(status: status, style: .compact)
                StatusBadge(status: status, style: .pill)
                StatusBadge(status: status, style: .full)
            }
        }
    }
    .padding()
}

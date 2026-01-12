import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = SpacingTokens.md
    var cornerRadius: CGFloat = RadiusTokens.lg

    init(
        padding: CGFloat = SpacingTokens.md,
        cornerRadius: CGFloat = RadiusTokens.lg,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        content
            .padding(padding)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(ColorTokens.glassBorder, lineWidth: 0.5)
            )
    }
}

struct SolidCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = SpacingTokens.md
    var cornerRadius: CGFloat = RadiusTokens.lg
    var backgroundColor: Color = ColorTokens.backgroundSecondary

    init(
        padding: CGFloat = SpacingTokens.md,
        cornerRadius: CGFloat = RadiusTokens.lg,
        backgroundColor: Color = ColorTokens.backgroundSecondary,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [.blue, .purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        VStack(spacing: SpacingTokens.lg) {
            GlassCard {
                VStack(alignment: .leading, spacing: SpacingTokens.xs) {
                    Text("Glass Card")
                        .font(TypographyTokens.titleMedium)
                    Text("With ultra thin material background")
                        .font(TypographyTokens.bodySmall)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            SolidCard {
                VStack(alignment: .leading, spacing: SpacingTokens.xs) {
                    Text("Solid Card")
                        .font(TypographyTokens.titleMedium)
                    Text("With solid background color")
                        .font(TypographyTokens.bodySmall)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
    }
}

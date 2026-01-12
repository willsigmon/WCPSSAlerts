import SwiftUI

struct LoadingView: View {
    var message: String = "Loading..."

    var body: some View {
        VStack(spacing: SpacingTokens.md) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(ColorTokens.primary)

            Text(message)
                .font(TypographyTokens.bodyMedium)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorView: View {
    let message: String
    var retryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: SpacingTokens.lg) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(ColorTokens.warning)

            Text("Something went wrong")
                .font(TypographyTokens.titleMedium)

            Text(message)
                .font(TypographyTokens.bodyMedium)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            if let retry = retryAction {
                Button(action: retry) {
                    Label("Try Again", systemImage: "arrow.clockwise")
                        .font(TypographyTokens.labelLarge)
                }
                .buttonStyle(.borderedProminent)
                .tint(ColorTokens.primary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var action: (() -> Void)?
    var actionLabel: String = "Refresh"

    var body: some View {
        VStack(spacing: SpacingTokens.lg) {
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundColor(.secondary.opacity(0.5))

            VStack(spacing: SpacingTokens.xs) {
                Text(title)
                    .font(TypographyTokens.titleMedium)

                Text(message)
                    .font(TypographyTokens.bodyMedium)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let action = action {
                Button(action: action) {
                    Text(actionLabel)
                        .font(TypographyTokens.labelLarge)
                }
                .buttonStyle(.bordered)
                .tint(ColorTokens.primary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    VStack {
        LoadingView()
        Divider()
        ErrorView(message: "Failed to load data", retryAction: {})
        Divider()
        EmptyStateView(
            icon: "bell.slash",
            title: "No Alerts",
            message: "There are no active alerts at this time.",
            action: {}
        )
    }
}

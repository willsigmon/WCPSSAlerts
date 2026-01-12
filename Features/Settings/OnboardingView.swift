import SwiftUI

struct OnboardingView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var currentPage = 0
    @State private var selectedDistrict: District = .wcpss

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                welcomePage.tag(0)
                districtPage.tag(1)
                notificationsPage.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)

            // Page indicators and button
            VStack(spacing: SpacingTokens.lg) {
                HStack(spacing: SpacingTokens.xs) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(index == currentPage ? ColorTokens.primary : Color.secondary.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }

                Button {
                    if currentPage < 2 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        appViewModel.setDistrict(selectedDistrict)
                        appViewModel.completeOnboarding()
                    }
                } label: {
                    Text(currentPage < 2 ? "Continue" : "Get Started")
                        .font(TypographyTokens.labelLarge)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, SpacingTokens.md)
                        .background(ColorTokens.primary)
                        .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.md))
                }
                .padding(.horizontal, SpacingTokens.xl)
            }
            .padding(.bottom, SpacingTokens.xl)
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Welcome Page
    private var welcomePage: some View {
        VStack(spacing: SpacingTokens.xl) {
            Spacer()

            Image(systemName: "snowflake")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [ColorTokens.primary, ColorTokens.secondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: SpacingTokens.sm) {
                Text("WCPSS Alerts")
                    .font(TypographyTokens.displaySmall)

                Text("Know before the snow")
                    .font(TypographyTokens.titleMedium)
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: SpacingTokens.md) {
                featureRow(icon: "bell.badge.fill", title: "Instant Notifications", description: "Get alerts the moment closures are announced")
                featureRow(icon: "chart.line.uptrend.xyaxis", title: "AI Predictions", description: "See closure probability before official announcements")
                featureRow(icon: "map.fill", title: "Regional Coverage", description: "Track all NC Triangle school districts")
            }
            .padding(.horizontal, SpacingTokens.xl)

            Spacer()
            Spacer()
        }
    }

    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: SpacingTokens.md) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(ColorTokens.primary)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(TypographyTokens.labelLarge)
                Text(description)
                    .font(TypographyTokens.bodySmall)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - District Page
    private var districtPage: some View {
        VStack(spacing: SpacingTokens.xl) {
            Spacer()

            VStack(spacing: SpacingTokens.sm) {
                Text("Select Your District")
                    .font(TypographyTokens.headlineMedium)

                Text("Choose your primary school district for personalized alerts")
                    .font(TypographyTokens.bodyMedium)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: SpacingTokens.sm) {
                ForEach(District.allCases) { district in
                    districtCard(district)
                }
            }
            .padding(.horizontal)

            Spacer()
            Spacer()
        }
    }

    private func districtCard(_ district: District) -> some View {
        Button {
            selectedDistrict = district
        } label: {
            VStack(spacing: SpacingTokens.xs) {
                Text(district.abbreviation)
                    .font(TypographyTokens.titleLarge)
                    .fontWeight(.bold)
                Text(district.county)
                    .font(TypographyTokens.labelSmall)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, SpacingTokens.lg)
            .background(
                selectedDistrict == district
                    ? ColorTokens.primary.opacity(0.1)
                    : Color(.secondarySystemBackground)
            )
            .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.md))
            .overlay(
                RoundedRectangle(cornerRadius: RadiusTokens.md)
                    .strokeBorder(
                        selectedDistrict == district
                            ? ColorTokens.primary
                            : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Notifications Page
    private var notificationsPage: some View {
        VStack(spacing: SpacingTokens.xl) {
            Spacer()

            Image(systemName: "bell.badge.fill")
                .font(.system(size: 60))
                .foregroundColor(ColorTokens.primary)

            VStack(spacing: SpacingTokens.sm) {
                Text("Stay Informed")
                    .font(TypographyTokens.headlineMedium)

                Text("Enable notifications to get instant alerts when closure decisions are made")
                    .font(TypographyTokens.bodyMedium)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, SpacingTokens.xl)
            }

            Button {
                Task {
                    _ = await appViewModel.requestNotifications()
                }
            } label: {
                Label("Enable Notifications", systemImage: "bell.fill")
                    .font(TypographyTokens.labelLarge)
                    .foregroundColor(ColorTokens.primary)
            }
            .buttonStyle(.bordered)
            .tint(ColorTokens.primary)

            Text("You can change this later in Settings")
                .font(TypographyTokens.labelSmall)
                .foregroundColor(.secondary)

            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AppViewModel())
}

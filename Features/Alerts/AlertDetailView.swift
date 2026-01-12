import SwiftUI

struct AlertDetailView: View {
    let alert: ClosureAlert

    var body: some View {
        ScrollView {
            VStack(spacing: SpacingTokens.lg) {
                // Header
                headerSection

                // Weather Factors
                weatherFactorsCard

                // Reasoning
                reasoningCard

                // Timeline
                if let window = alert.criticalWindow {
                    timelineCard(window)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(alert.district.abbreviation)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        GlassCard(padding: SpacingTokens.lg) {
            VStack(spacing: SpacingTokens.md) {
                HStack {
                    VStack(alignment: .leading, spacing: SpacingTokens.xxs) {
                        Text(alert.district.fullName)
                            .font(TypographyTokens.titleMedium)
                        Text(alert.timestamp, style: .date)
                            .font(TypographyTokens.labelSmall)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    StatusBadge(status: alert.status, style: .full)
                }

                Divider()

                HStack(spacing: SpacingTokens.xl) {
                    ProbabilityGauge(probability: alert.probability, size: .medium)

                    VStack(alignment: .leading, spacing: SpacingTokens.xs) {
                        Text(alert.title)
                            .font(TypographyTokens.bodyLarge)

                        Text(alert.description)
                            .font(TypographyTokens.bodySmall)
                            .foregroundColor(.secondary)

                        HStack {
                            Label(alert.confidence.displayName, systemImage: "chart.bar.fill")
                                .font(TypographyTokens.labelSmall)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }

    private var weatherFactorsCard: some View {
        SolidCard {
            VStack(alignment: .leading, spacing: SpacingTokens.sm) {
                Label("Weather Factors", systemImage: "cloud.sun.fill")
                    .font(TypographyTokens.titleSmall)
                    .foregroundColor(.secondary)

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: SpacingTokens.sm) {
                    weatherFactorRow(
                        icon: "thermometer",
                        label: "Temperature",
                        value: "\(Int(alert.weatherFactors.temperature))°F"
                    )
                    weatherFactorRow(
                        icon: "snowflake",
                        label: "Snowfall",
                        value: "\(alert.weatherFactors.snowfall)\""
                    )
                    weatherFactorRow(
                        icon: "wind",
                        label: "Wind Speed",
                        value: "\(Int(alert.weatherFactors.windSpeed)) mph"
                    )
                    weatherFactorRow(
                        icon: "car.side.rear.and.exclamationmark",
                        label: "Ice Risk",
                        value: alert.weatherFactors.iceRisk.rawValue.capitalized
                    )
                    weatherFactorRow(
                        icon: "drop.fill",
                        label: "Precipitation",
                        value: "\(alert.weatherFactors.precipitation)\""
                    )
                }
            }
        }
    }

    private func weatherFactorRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: SpacingTokens.sm) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(ColorTokens.primary)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(TypographyTokens.labelSmall)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(TypographyTokens.labelMedium)
                    .fontWeight(.semibold)
            }

            Spacer()
        }
        .padding(SpacingTokens.sm)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.sm))
    }

    private var reasoningCard: some View {
        SolidCard {
            VStack(alignment: .leading, spacing: SpacingTokens.sm) {
                Label("Analysis", systemImage: "brain.head.profile")
                    .font(TypographyTokens.titleSmall)
                    .foregroundColor(.secondary)

                ForEach(alert.reasoning, id: \.self) { reason in
                    HStack(alignment: .top, spacing: SpacingTokens.sm) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(ColorTokens.primary)
                            .padding(.top, 2)

                        Text(reason)
                            .font(TypographyTokens.bodySmall)
                    }
                }
            }
        }
    }

    private func timelineCard(_ window: ClosureAlert.CriticalWindow) -> some View {
        SolidCard {
            VStack(alignment: .leading, spacing: SpacingTokens.sm) {
                Label("Critical Time Window", systemImage: "clock.fill")
                    .font(TypographyTokens.titleSmall)
                    .foregroundColor(.secondary)

                HStack {
                    VStack(alignment: .leading) {
                        Text("Start")
                            .font(TypographyTokens.labelSmall)
                            .foregroundColor(.secondary)
                        Text(window.start, style: .time)
                            .font(TypographyTokens.titleMedium)
                    }

                    Spacer()

                    Image(systemName: "arrow.right")
                        .foregroundColor(.secondary)

                    Spacer()

                    VStack(alignment: .trailing) {
                        Text("End")
                            .font(TypographyTokens.labelSmall)
                            .foregroundColor(.secondary)
                        Text(window.end, style: .time)
                            .font(TypographyTokens.titleMedium)
                    }
                }
                .padding(.vertical, SpacingTokens.sm)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AlertDetailView(alert: ClosureAlert(
            id: "1",
            district: .wcpss,
            status: .delay2hr,
            probability: 75,
            confidence: .high,
            title: "2-Hour Delay Expected",
            description: "Due to icy road conditions overnight",
            reasoning: [
                "Temperatures expected to drop below freezing overnight",
                "Light freezing rain forecast between 2-5 AM",
                "Road treatment crews will need time to clear secondary roads"
            ],
            criticalWindow: .init(
                start: Date().addingTimeInterval(-3600 * 4),
                end: Date().addingTimeInterval(3600 * 2)
            ),
            weatherFactors: .init(
                temperature: 28,
                snowfall: 0.5,
                windSpeed: 12,
                iceRisk: .moderate,
                precipitation: 0.1
            ),
            timestamp: Date()
        ))
    }
}

import SwiftUI

struct DashboardView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var viewModel = DashboardViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: SpacingTokens.lg) {
                    // Hero Card - Main Prediction
                    heroCard

                    // Weather Summary
                    weatherCard

                    // Quick Status Grid
                    districtGrid

                    // Recent Activity
                    if !viewModel.recentAlerts.isEmpty {
                        recentAlertsSection
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("WCPSS Alerts")
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.loadData()
            }
        }
    }

    // MARK: - Hero Card
    private var heroCard: some View {
        GlassCard(padding: SpacingTokens.lg) {
            VStack(spacing: SpacingTokens.lg) {
                // District name and status
                HStack {
                    VStack(alignment: .leading, spacing: SpacingTokens.xxs) {
                        Text(appViewModel.selectedDistrict.fullName)
                            .font(TypographyTokens.titleMedium)
                            .fontWeight(.semibold)

                        Text("Last updated: \(viewModel.lastUpdatedText)")
                            .font(TypographyTokens.labelSmall)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    if let prediction = viewModel.prediction {
                        StatusBadge(status: prediction.recommendation, style: .full)
                    }
                }

                // Probability gauge
                if let prediction = viewModel.prediction {
                    HStack(spacing: SpacingTokens.xl) {
                        ProbabilityGauge(probability: prediction.probability, size: .large)

                        VStack(alignment: .leading, spacing: SpacingTokens.sm) {
                            Label {
                                Text("Closure Probability")
                                    .font(TypographyTokens.labelMedium)
                            } icon: {
                                Image(systemName: "percent")
                            }
                            .foregroundColor(.secondary)

                            Text(probabilityDescription(prediction.probability))
                                .font(TypographyTokens.bodyMedium)

                            if let window = prediction.criticalTimeWindow {
                                Label {
                                    Text(formatTimeWindow(window))
                                        .font(TypographyTokens.labelSmall)
                                } icon: {
                                    Image(systemName: "clock")
                                }
                                .foregroundColor(.secondary)
                            }
                        }

                        Spacer()
                    }
                }

                // Key factors
                if let prediction = viewModel.prediction {
                    Divider()
                    keyFactorsRow(prediction.factors)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: RadiusTokens.lg)
                .fill(
                    LinearGradient(
                        colors: [
                            ColorTokens.primary.opacity(0.1),
                            ColorTokens.secondary.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }

    private func keyFactorsRow(_ factors: PredictionFactors) -> some View {
        HStack(spacing: SpacingTokens.md) {
            factorPill(icon: "thermometer", value: "\(Int(factors.temperature))°F", label: "Temp")
            factorPill(icon: "snowflake", value: "\(factors.snowfall)\"", label: "Snow")
            factorPill(icon: "wind", value: factors.windSpeed, label: "Wind")
            factorPill(icon: "car.side.rear.and.exclamationmark", value: factors.iceRisk, label: "Ice")
        }
    }

    private func factorPill(icon: String, value: String, label: String) -> some View {
        VStack(spacing: SpacingTokens.xxs) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(ColorTokens.primary)

            Text(value)
                .font(TypographyTokens.labelMedium)
                .fontWeight(.semibold)

            Text(label)
                .font(TypographyTokens.labelSmall)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, SpacingTokens.xs)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: RadiusTokens.sm))
    }

    // MARK: - Weather Card
    private var weatherCard: some View {
        SolidCard {
            HStack {
                if let weather = viewModel.currentWeather {
                    Image(systemName: weather.conditionSymbol)
                        .font(.system(size: 36))
                        .symbolRenderingMode(.multicolor)

                    VStack(alignment: .leading, spacing: SpacingTokens.xxs) {
                        Text("\(Int(weather.temperature))°F")
                            .font(TypographyTokens.headlineMedium)
                        Text(weather.condition)
                            .font(TypographyTokens.bodySmall)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: SpacingTokens.xxs) {
                        Label("\(Int(weather.precipitationChance * 100))%", systemImage: "drop.fill")
                        Label("\(Int(weather.windSpeed)) mph", systemImage: "wind")
                    }
                    .font(TypographyTokens.labelSmall)
                    .foregroundColor(.secondary)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    // MARK: - District Grid
    private var districtGrid: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.sm) {
            Text("Triangle Districts")
                .font(TypographyTokens.titleSmall)
                .foregroundColor(.secondary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: SpacingTokens.sm) {
                ForEach(viewModel.districtPredictions) { dp in
                    districtCard(dp)
                }
            }
        }
    }

    private func districtCard(_ dp: DistrictPrediction) -> some View {
        SolidCard(padding: SpacingTokens.sm) {
            HStack {
                VStack(alignment: .leading, spacing: SpacingTokens.xxs) {
                    Text(dp.district.abbreviation)
                        .font(TypographyTokens.labelLarge)
                        .fontWeight(.bold)
                    Text(dp.district.county)
                        .font(TypographyTokens.labelSmall)
                        .foregroundColor(.secondary)
                }

                Spacer()

                ProbabilityGauge(probability: dp.prediction.probability, size: .small)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: RadiusTokens.lg)
                .strokeBorder(
                    dp.district == appViewModel.selectedDistrict
                        ? ColorTokens.primary
                        : Color.clear,
                    lineWidth: 2
                )
        )
    }

    // MARK: - Recent Alerts
    private var recentAlertsSection: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.sm) {
            HStack {
                Text("Recent Activity")
                    .font(TypographyTokens.titleSmall)
                    .foregroundColor(.secondary)
                Spacer()
                NavigationLink("See All") {
                    AlertsListView()
                }
                .font(TypographyTokens.labelSmall)
            }

            ForEach(viewModel.recentAlerts.prefix(3)) { alert in
                alertRow(alert)
            }
        }
    }

    private func alertRow(_ alert: ClosureAlert) -> some View {
        SolidCard(padding: SpacingTokens.sm) {
            HStack(spacing: SpacingTokens.sm) {
                StatusBadge(status: alert.status, style: .compact)

                VStack(alignment: .leading, spacing: SpacingTokens.xxs) {
                    Text(alert.title)
                        .font(TypographyTokens.labelMedium)
                    Text(alert.timestamp, style: .relative)
                        .font(TypographyTokens.labelSmall)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Helpers
    private func probabilityDescription(_ probability: Int) -> String {
        switch probability {
        case 0..<20: return "Schools likely to operate normally"
        case 20..<40: return "Low chance of delays"
        case 40..<60: return "Moderate chance of delays"
        case 60..<80: return "High chance of delay or closure"
        default: return "Very likely to close or delay"
        }
    }

    private func formatTimeWindow(_ window: ClosurePrediction.TimeWindow) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        return "Critical: \(formatter.string(from: window.start)) - \(formatter.string(from: window.end))"
    }
}

#Preview {
    DashboardView()
        .environment(AppViewModel())
}

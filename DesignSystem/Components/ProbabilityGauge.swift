import SwiftUI

struct ProbabilityGauge: View {
    let probability: Int
    let size: GaugeSize

    enum GaugeSize {
        case small, medium, large

        var diameter: CGFloat {
            switch self {
            case .small: return 80
            case .medium: return 120
            case .large: return 200
            }
        }

        var lineWidth: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 12
            case .large: return 16
            }
        }

        var font: Font {
            switch self {
            case .small: return TypographyTokens.monoSmall
            case .medium: return TypographyTokens.monoMedium
            case .large: return TypographyTokens.monoLarge
            }
        }
    }

    private var progress: Double {
        Double(probability) / 100.0
    }

    private var color: Color {
        ColorTokens.probabilityColor(probability)
    }

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(color.opacity(0.2), lineWidth: size.lineWidth)

            // Progress arc
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: size.lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(duration: 0.8), value: probability)

            // Percentage text
            VStack(spacing: 0) {
                Text("\(probability)")
                    .font(size.font)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                    .contentTransition(.numericText())
                    .animation(.spring(duration: 0.3), value: probability)

                Text("%")
                    .font(TypographyTokens.labelSmall)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: size.diameter, height: size.diameter)
    }
}

#Preview {
    VStack(spacing: SpacingTokens.xl) {
        ProbabilityGauge(probability: 75, size: .large)
        HStack(spacing: SpacingTokens.lg) {
            ProbabilityGauge(probability: 25, size: .medium)
            ProbabilityGauge(probability: 50, size: .medium)
        }
        HStack(spacing: SpacingTokens.md) {
            ProbabilityGauge(probability: 10, size: .small)
            ProbabilityGauge(probability: 45, size: .small)
            ProbabilityGauge(probability: 90, size: .small)
        }
    }
    .padding()
}

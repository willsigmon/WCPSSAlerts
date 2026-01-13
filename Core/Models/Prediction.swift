import Foundation

struct ClosurePrediction: Codable, Sendable, Equatable {
    let probability: Int
    let recommendation: ClosureStatus
    let confidence: ConfidenceLevel
    let factors: PredictionFactors
    let reasoning: [String]
    let criticalTimeWindow: TimeWindow?
    let lastUpdated: Date

    struct TimeWindow: Codable, Sendable, Equatable {
        let start: Date
        let end: Date
    }

    /// Determines if this prediction represents a significant change from another
    /// Used to prevent false alerts from minor fluctuations
    func hasSignificantChange(from other: ClosurePrediction?) -> Bool {
        guard let other = other else { return true }

        // Status change is always significant
        if recommendation != other.recommendation {
            return true
        }

        // Probability change of 15+ points is significant
        if abs(probability - other.probability) >= 15 {
            return true
        }

        // Confidence level change is significant
        if confidence != other.confidence {
            return true
        }

        return false
    }

    /// Returns true if this prediction warrants user notification
    var shouldNotify: Bool {
        // Only notify for elevated probability or non-open status
        probability >= 40 || recommendation != .open
    }
}

struct PredictionFactors: Codable, Sendable, Equatable {
    let temperature: Double
    let snowfall: Double
    let windSpeed: String
    let iceRisk: String
    let precipitation: Double?
    let visibility: Double?
    let roadConditions: String?
}

struct DistrictPrediction: Identifiable, Codable, Sendable, Equatable {
    var id: String { district.rawValue }
    let district: District
    let prediction: ClosurePrediction
}

import Foundation

struct ClosurePrediction: Codable, Sendable {
    let probability: Int
    let recommendation: ClosureStatus
    let confidence: ConfidenceLevel
    let factors: PredictionFactors
    let reasoning: [String]
    let criticalTimeWindow: TimeWindow?
    let lastUpdated: Date

    struct TimeWindow: Codable, Sendable {
        let start: Date
        let end: Date
    }
}

struct PredictionFactors: Codable, Sendable {
    let temperature: Double
    let snowfall: Double
    let windSpeed: String
    let iceRisk: String
    let precipitation: Double?
    let visibility: Double?
    let roadConditions: String?
}

struct DistrictPrediction: Identifiable, Codable, Sendable {
    var id: String { district.rawValue }
    let district: District
    let prediction: ClosurePrediction
}

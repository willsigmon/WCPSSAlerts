import Foundation

struct ClosureAlert: Identifiable, Codable, Sendable, Equatable {
    let id: String
    let district: District
    let status: ClosureStatus
    let probability: Int
    let confidence: ConfidenceLevel
    let title: String
    let description: String
    let reasoning: [String]
    let criticalWindow: CriticalWindow?
    let weatherFactors: WeatherFactors
    let timestamp: Date
    var isRead: Bool = false

    struct CriticalWindow: Codable, Sendable, Equatable {
        let start: Date
        let end: Date
    }

    struct WeatherFactors: Codable, Sendable, Equatable {
        let temperature: Double
        let snowfall: Double
        let windSpeed: Double
        let iceRisk: IceRisk
        let precipitation: Double
    }

    /// Determines if this alert represents a significant change from another
    func hasSignificantChange(from other: ClosureAlert?) -> Bool {
        guard let other = other else { return true }

        // Status change is always significant
        if status != other.status {
            return true
        }

        // Probability change of 15+ points is significant
        if abs(probability - other.probability) >= 15 {
            return true
        }

        return false
    }
}

enum ClosureStatus: String, Codable, CaseIterable, Sendable {
    case open = "open"
    case delay2hr = "2hr_delay"
    case delay3hr = "3hr_delay"
    case closed = "closed"
    case eLearning = "remote"
    case earlyRelease = "early_release"

    var displayName: String {
        switch self {
        case .open: return "Open"
        case .delay2hr: return "2-Hour Delay"
        case .delay3hr: return "3-Hour Delay"
        case .closed: return "Closed"
        case .eLearning: return "Remote Learning"
        case .earlyRelease: return "Early Release"
        }
    }

    var icon: String {
        switch self {
        case .open: return "checkmark.circle.fill"
        case .delay2hr, .delay3hr: return "clock.fill"
        case .closed: return "xmark.circle.fill"
        case .eLearning: return "laptopcomputer"
        case .earlyRelease: return "arrow.right.circle.fill"
        }
    }
}

enum ConfidenceLevel: String, Codable, CaseIterable, Sendable {
    case low
    case medium
    case high
    case certain

    var displayName: String {
        rawValue.capitalized
    }
}

enum IceRisk: String, Codable, CaseIterable, Sendable {
    case none
    case low
    case moderate
    case high
    case severe
}

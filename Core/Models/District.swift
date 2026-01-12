import Foundation

enum District: String, Codable, CaseIterable, Identifiable, Sendable {
    case wcpss = "WCPSS"
    case dps = "DPS"
    case chccs = "CHCCS"
    case jcps = "JCPS"
    case ocps = "OCPS"
    case gcps = "GCPS"

    var id: String { rawValue }

    var fullName: String {
        switch self {
        case .wcpss: return "Wake County Public Schools"
        case .dps: return "Durham Public Schools"
        case .chccs: return "Chapel Hill-Carrboro City Schools"
        case .jcps: return "Johnston County Public Schools"
        case .ocps: return "Orange County Public Schools"
        case .gcps: return "Granville County Public Schools"
        }
    }

    var abbreviation: String { rawValue }

    var county: String {
        switch self {
        case .wcpss: return "Wake"
        case .dps: return "Durham"
        case .chccs: return "Orange"
        case .jcps: return "Johnston"
        case .ocps: return "Orange"
        case .gcps: return "Granville"
        }
    }

    var studentCount: Int {
        switch self {
        case .wcpss: return 160000
        case .dps: return 32000
        case .chccs: return 12000
        case .jcps: return 36000
        case .ocps: return 7500
        case .gcps: return 8500
        }
    }
}

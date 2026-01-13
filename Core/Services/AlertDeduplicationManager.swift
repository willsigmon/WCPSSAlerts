import Foundation

/// Manages alert deduplication to prevent false/duplicate notifications
/// Persists state to UserDefaults to survive app restarts
@MainActor
public final class AlertDeduplicationManager {

    // MARK: - Storage Keys
    private enum StorageKey {
        static let lastNotifiedPredictions = "lastNotifiedPredictions"
        static let lastNotificationTimestamps = "lastNotificationTimestamps"
        static let notifiedAlertIds = "notifiedAlertIds"
    }

    // MARK: - Configuration
    /// Minimum interval between notifications for the same district (in seconds)
    private let minimumNotificationInterval: TimeInterval = 3600 // 1 hour

    /// Maximum number of alert IDs to track (prevents unbounded growth)
    private let maxTrackedAlertIds = 100

    // MARK: - State
    private var lastNotifiedPredictions: [String: PredictionSnapshot] = [:]
    private var lastNotificationTimestamps: [String: Date] = [:]
    private var notifiedAlertIds: Set<String> = []

    // MARK: - Init
    init() {
        loadPersistedState()
    }

    // MARK: - Prediction Deduplication

    /// Determines if a prediction should trigger a notification
    /// Returns true only if the prediction represents a significant, new change
    func shouldNotify(for prediction: ClosurePrediction, district: District) -> Bool {
        let districtKey = district.rawValue

        // Check rate limiting first
        if let lastTimestamp = lastNotificationTimestamps[districtKey] {
            let timeSinceLastNotification = Date().timeIntervalSince(lastTimestamp)
            if timeSinceLastNotification < minimumNotificationInterval {
                // Exception: Allow immediate notification for critical status changes
                let lastSnapshot = lastNotifiedPredictions[districtKey]
                let statusChanged = lastSnapshot?.recommendation != prediction.recommendation
                let isNowCritical = prediction.recommendation == .closed || prediction.probability >= 80

                if !(statusChanged && isNowCritical) {
                    return false
                }
            }
        }

        // Check if prediction meets notification threshold
        guard prediction.shouldNotify else {
            return false
        }

        // Check for significant change
        let lastSnapshot = lastNotifiedPredictions[districtKey]
        let hasSignificantChange = prediction.hasSignificantChange(
            from: lastSnapshot.map { snapshot in
                // Reconstruct a minimal prediction for comparison
                ClosurePrediction(
                    probability: snapshot.probability,
                    recommendation: snapshot.recommendation,
                    confidence: snapshot.confidence,
                    factors: PredictionFactors(
                        temperature: 0, snowfall: 0, windSpeed: "",
                        iceRisk: "", precipitation: nil, visibility: nil, roadConditions: nil
                    ),
                    reasoning: [],
                    criticalTimeWindow: nil,
                    lastUpdated: snapshot.lastUpdated
                )
            }
        )

        return hasSignificantChange
    }

    /// Records that a notification was sent for a prediction
    func recordNotification(for prediction: ClosurePrediction, district: District) {
        let districtKey = district.rawValue
        let snapshot = PredictionSnapshot(
            probability: prediction.probability,
            recommendation: prediction.recommendation,
            confidence: prediction.confidence,
            lastUpdated: prediction.lastUpdated
        )

        lastNotifiedPredictions[districtKey] = snapshot
        lastNotificationTimestamps[districtKey] = Date()

        persistState()
    }

    // MARK: - Alert Deduplication

    /// Checks if an alert has already been notified
    func hasNotified(alertId: String) -> Bool {
        notifiedAlertIds.contains(alertId)
    }

    /// Records that an alert notification was sent
    func recordAlertNotification(alertId: String) {
        notifiedAlertIds.insert(alertId)

        // Prune old entries if needed
        if notifiedAlertIds.count > maxTrackedAlertIds {
            // Remove oldest entries (simple approach: remove random ones)
            let toRemove = notifiedAlertIds.count - maxTrackedAlertIds
            for _ in 0..<toRemove {
                if let first = notifiedAlertIds.first {
                    notifiedAlertIds.remove(first)
                }
            }
        }

        persistState()
    }

    // MARK: - State Management

    /// Clears all deduplication state (useful for testing or user reset)
    func clearAllState() {
        lastNotifiedPredictions.removeAll()
        lastNotificationTimestamps.removeAll()
        notifiedAlertIds.removeAll()
        persistState()
    }

    /// Clears state for a specific district
    func clearState(for district: District) {
        let districtKey = district.rawValue
        lastNotifiedPredictions.removeValue(forKey: districtKey)
        lastNotificationTimestamps.removeValue(forKey: districtKey)
        persistState()
    }

    // MARK: - Persistence

    private func loadPersistedState() {
        let defaults = UserDefaults.standard

        // Load prediction snapshots
        if let data = defaults.data(forKey: StorageKey.lastNotifiedPredictions),
           let decoded = try? JSONDecoder().decode([String: PredictionSnapshot].self, from: data) {
            lastNotifiedPredictions = decoded
        }

        // Load timestamps
        if let data = defaults.data(forKey: StorageKey.lastNotificationTimestamps),
           let decoded = try? JSONDecoder().decode([String: Date].self, from: data) {
            lastNotificationTimestamps = decoded
        }

        // Load notified alert IDs
        if let ids = defaults.stringArray(forKey: StorageKey.notifiedAlertIds) {
            notifiedAlertIds = Set(ids)
        }
    }

    private func persistState() {
        let defaults = UserDefaults.standard

        // Save prediction snapshots
        if let data = try? JSONEncoder().encode(lastNotifiedPredictions) {
            defaults.set(data, forKey: StorageKey.lastNotifiedPredictions)
        }

        // Save timestamps
        if let data = try? JSONEncoder().encode(lastNotificationTimestamps) {
            defaults.set(data, forKey: StorageKey.lastNotificationTimestamps)
        }

        // Save notified alert IDs
        defaults.set(Array(notifiedAlertIds), forKey: StorageKey.notifiedAlertIds)
    }
}

// MARK: - Supporting Types

/// Lightweight snapshot of prediction state for deduplication comparison
private struct PredictionSnapshot: Codable {
    let probability: Int
    let recommendation: ClosureStatus
    let confidence: ConfidenceLevel
    let lastUpdated: Date
}

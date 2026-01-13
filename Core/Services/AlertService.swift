import Foundation

@MainActor
public final class AlertService {
    private let apiClient: APIClient
    private var cachedPrediction: ClosurePrediction?
    private var cacheTimestamp: Date?
    private let cacheDuration: TimeInterval = 300 // 5 minutes

    // Alert caching
    private var cachedAlerts: [ClosureAlert] = []
    private var alertsCacheTimestamp: Date?
    private let alertsCacheDuration: TimeInterval = 120 // 2 minutes

    init(apiClient: APIClient? = nil) {
        self.apiClient = apiClient ?? DIContainer.shared.apiClient
    }

    // MARK: - Prediction
    func fetchPrediction(forceRefresh: Bool = false) async throws -> ClosurePrediction {
        // Return cached if valid
        if !forceRefresh,
           let cached = cachedPrediction,
           let timestamp = cacheTimestamp,
           Date().timeIntervalSince(timestamp) < cacheDuration {
            return cached
        }

        // Fetch from API
        struct PredictionResponse: Decodable {
            let prediction: ClosurePrediction
        }

        let response: PredictionResponse = try await apiClient.get("/prediction")
        cachedPrediction = response.prediction
        cacheTimestamp = Date()
        return response.prediction
    }

    /// Fetches prediction and sends notification if significant change detected
    func fetchPredictionWithNotification(
        for district: District,
        notificationService: NotificationService
    ) async throws -> ClosurePrediction {
        let prediction = try await fetchPrediction(forceRefresh: true)

        // Only notify if authorized
        if await notificationService.isAuthorized() {
            await notificationService.notifyIfSignificant(
                prediction: prediction,
                district: district
            )
        }

        return prediction
    }

    // MARK: - All Districts
    func fetchAllDistricts() async throws -> [DistrictPrediction] {
        // For now, fetch the main prediction and create district predictions
        // In production, this would call a dedicated endpoint
        let prediction = try await fetchPrediction()

        return District.allCases.map { district in
            DistrictPrediction(
                district: district,
                prediction: prediction
            )
        }
    }

    // MARK: - Alerts History
    func fetchRecentAlerts(forceRefresh: Bool = false) async throws -> [ClosureAlert] {
        // Return cached if valid
        if !forceRefresh,
           !cachedAlerts.isEmpty,
           let timestamp = alertsCacheTimestamp,
           Date().timeIntervalSince(timestamp) < alertsCacheDuration {
            return cachedAlerts
        }

        // Try to fetch from API
        do {
            struct AlertsResponse: Decodable {
                let alerts: [ClosureAlert]
            }

            let response: AlertsResponse = try await apiClient.get("/alerts")
            cachedAlerts = response.alerts
            alertsCacheTimestamp = Date()
            return response.alerts
        } catch {
            // If API fails, return empty array (graceful degradation)
            // This prevents the app from crashing if /alerts endpoint isn't ready
            print("Failed to fetch alerts from API: \(error)")
            return cachedAlerts.isEmpty ? [] : cachedAlerts
        }
    }

    /// Fetches alerts and sends notifications for any new ones
    func fetchAlertsWithNotification(
        notificationService: NotificationService
    ) async throws -> [ClosureAlert] {
        let alerts = try await fetchRecentAlerts(forceRefresh: true)

        // Only notify if authorized
        if await notificationService.isAuthorized() {
            for alert in alerts {
                await notificationService.notifyIfNew(alert: alert)
            }
        }

        return alerts
    }

    // MARK: - Cache Management
    func clearCache() {
        cachedPrediction = nil
        cacheTimestamp = nil
        cachedAlerts = []
        alertsCacheTimestamp = nil
    }

    func clearPredictionCache() {
        cachedPrediction = nil
        cacheTimestamp = nil
    }

    func clearAlertsCache() {
        cachedAlerts = []
        alertsCacheTimestamp = nil
    }

    // MARK: - Cache State
    var hasCachedPrediction: Bool {
        guard let timestamp = cacheTimestamp else { return false }
        return Date().timeIntervalSince(timestamp) < cacheDuration
    }

    var hasCachedAlerts: Bool {
        guard let timestamp = alertsCacheTimestamp else { return false }
        return Date().timeIntervalSince(timestamp) < alertsCacheDuration
    }
}

import Foundation

@MainActor
public final class AlertService {
    private let apiClient: APIClient
    private var cachedPrediction: ClosurePrediction?
    private var cacheTimestamp: Date?
    private let cacheDuration: TimeInterval = 300 // 5 minutes

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
    func fetchRecentAlerts() async throws -> [ClosureAlert] {
        // Placeholder - would fetch from /api/alerts
        return []
    }

    // MARK: - Cache Management
    func clearCache() {
        cachedPrediction = nil
        cacheTimestamp = nil
    }
}

import SwiftUI

@MainActor
@Observable
final class DashboardViewModel {
    // MARK: - State
    var prediction: ClosurePrediction?
    var districtPredictions: [DistrictPrediction] = []
    var currentWeather: CurrentWeather?
    var recentAlerts: [ClosureAlert] = []
    var isLoading = false
    var error: String?

    var lastUpdatedText: String {
        guard let prediction = prediction else { return "Never" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: prediction.lastUpdated, relativeTo: Date())
    }

    // MARK: - Services
    private let alertService: AlertService
    private let weatherService: WeatherService

    init(
        alertService: AlertService = DIContainer.shared.alertService,
        weatherService: WeatherService = DIContainer.shared.weatherService
    ) {
        self.alertService = alertService
        self.weatherService = weatherService
    }

    // MARK: - Data Loading
    func loadData() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil

        async let predictionTask = loadPrediction()
        async let weatherTask = loadWeather()
        async let districtsTask = loadDistricts()
        async let alertsTask = loadRecentAlerts()

        await predictionTask
        await weatherTask
        await districtsTask
        await alertsTask

        isLoading = false
    }

    func refresh() async {
        alertService.clearCache()
        await loadData()
    }

    private func loadPrediction() async {
        do {
            prediction = try await alertService.fetchPrediction()
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func loadWeather() async {
        do {
            currentWeather = try await weatherService.fetchCurrentWeather()
        } catch {
            // Weather is non-critical, just log
            print("Failed to load weather: \(error)")
        }
    }

    private func loadDistricts() async {
        do {
            districtPredictions = try await alertService.fetchAllDistricts()
        } catch {
            print("Failed to load districts: \(error)")
        }
    }

    private func loadRecentAlerts() async {
        do {
            recentAlerts = try await alertService.fetchRecentAlerts()
        } catch {
            print("Failed to load alerts: \(error)")
        }
    }
}

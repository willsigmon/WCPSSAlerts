import SwiftUI

@MainActor
@Observable
final class AlertsViewModel {
    // MARK: - State
    var alerts: [ClosureAlert] = []
    var isLoading = false
    var error: String?

    // MARK: - Services
    private let alertService: AlertService

    init(alertService: AlertService = DIContainer.shared.alertService) {
        self.alertService = alertService
    }

    // MARK: - Actions
    func loadAlerts() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil

        do {
            alerts = try await alertService.fetchRecentAlerts()
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func refresh() async {
        alertService.clearCache()
        await loadAlerts()
    }

    func markAsRead(_ alert: ClosureAlert) {
        if let index = alerts.firstIndex(where: { $0.id == alert.id }) {
            alerts[index].isRead = true
        }
    }
}

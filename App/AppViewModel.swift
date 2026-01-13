import SwiftUI
import UserNotifications

@MainActor
@Observable
final class AppViewModel {
    // MARK: - State
    var hasCompletedOnboarding: Bool = false
    var selectedDistrict: District = .wcpss
    var notificationsEnabled: Bool = false

    // Notification preferences (per-district control)
    var notifyForSelectedDistrictOnly: Bool = true
    var notifyOnProbabilityThreshold: Int = 40 // Minimum probability to notify

    // MARK: - Services
    private let alertService: AlertService
    private let notificationService: NotificationService
    private let deduplicationManager: AlertDeduplicationManager

    // MARK: - Init
    init(
        alertService: AlertService = DIContainer.shared.alertService,
        notificationService: NotificationService = DIContainer.shared.notificationService,
        deduplicationManager: AlertDeduplicationManager = DIContainer.shared.deduplicationManager
    ) {
        self.alertService = alertService
        self.notificationService = notificationService
        self.deduplicationManager = deduplicationManager
    }

    // MARK: - Lifecycle
    func onAppear() {
        loadPersistedState()
        setupNotificationDelegate()
        Task {
            await checkNotificationStatus()
        }
    }

    private func setupNotificationDelegate() {
        // Set up the notification center delegate to handle foreground notifications
        UNUserNotificationCenter.current().delegate = notificationService
    }

    // MARK: - Persistence
    private func loadPersistedState() {
        let defaults = UserDefaults.standard
        hasCompletedOnboarding = defaults.bool(forKey: "hasCompletedOnboarding")

        if let districtRaw = defaults.string(forKey: "selectedDistrict"),
           let district = District(rawValue: districtRaw) {
            selectedDistrict = district
        }

        notifyForSelectedDistrictOnly = defaults.object(forKey: "notifyForSelectedDistrictOnly") as? Bool ?? true
        notifyOnProbabilityThreshold = defaults.object(forKey: "notifyOnProbabilityThreshold") as? Int ?? 40
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }

    func setDistrict(_ district: District) {
        selectedDistrict = district
        UserDefaults.standard.set(district.rawValue, forKey: "selectedDistrict")

        // Clear deduplication state for new district to ensure fresh notifications
        deduplicationManager.clearState(for: district)
    }

    func setNotifyForSelectedDistrictOnly(_ value: Bool) {
        notifyForSelectedDistrictOnly = value
        UserDefaults.standard.set(value, forKey: "notifyForSelectedDistrictOnly")
    }

    func setNotifyOnProbabilityThreshold(_ value: Int) {
        notifyOnProbabilityThreshold = value
        UserDefaults.standard.set(value, forKey: "notifyOnProbabilityThreshold")
    }

    // MARK: - Notifications
    private func checkNotificationStatus() async {
        notificationsEnabled = await notificationService.isAuthorized()
    }

    func requestNotifications() async -> Bool {
        let granted = await notificationService.requestAuthorization()
        notificationsEnabled = granted
        return granted
    }

    func disableNotifications() {
        notificationsEnabled = false
        notificationService.cancelAllNotifications()
    }

    // MARK: - Smart Data Fetching with Notifications

    /// Fetches prediction and optionally sends notification if significant change
    func fetchPredictionWithNotification() async throws -> ClosurePrediction {
        return try await alertService.fetchPredictionWithNotification(
            for: selectedDistrict,
            notificationService: notificationService
        )
    }

    /// Fetches alerts and optionally sends notifications for new ones
    func fetchAlertsWithNotification() async throws -> [ClosureAlert] {
        return try await alertService.fetchAlertsWithNotification(
            notificationService: notificationService
        )
    }

    // MARK: - Deduplication Management

    /// Resets all notification tracking (useful for testing or user-requested reset)
    func resetNotificationTracking() {
        deduplicationManager.clearAllState()
    }

    /// Resets notification tracking for current district only
    func resetCurrentDistrictNotifications() {
        deduplicationManager.clearState(for: selectedDistrict)
    }
}

import SwiftUI

@MainActor
@Observable
final class AppViewModel {
    // MARK: - State
    var hasCompletedOnboarding: Bool = false
    var selectedDistrict: District = .wcpss
    var notificationsEnabled: Bool = false

    // MARK: - Services
    private let alertService: AlertService
    private let notificationService: NotificationService

    // MARK: - Init
    init(
        alertService: AlertService = DIContainer.shared.alertService,
        notificationService: NotificationService = DIContainer.shared.notificationService
    ) {
        self.alertService = alertService
        self.notificationService = notificationService
    }

    // MARK: - Lifecycle
    func onAppear() {
        loadPersistedState()
        Task {
            await checkNotificationStatus()
        }
    }

    // MARK: - Persistence
    private func loadPersistedState() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        if let districtRaw = UserDefaults.standard.string(forKey: "selectedDistrict"),
           let district = District(rawValue: districtRaw) {
            selectedDistrict = district
        }
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }

    func setDistrict(_ district: District) {
        selectedDistrict = district
        UserDefaults.standard.set(district.rawValue, forKey: "selectedDistrict")
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
}

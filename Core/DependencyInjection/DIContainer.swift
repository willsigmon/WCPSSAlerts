import Foundation

/// Centralized dependency container for service resolution
@MainActor
public final class DIContainer {
    public static let shared = DIContainer()

    // MARK: - Services (lazily initialized)
    public lazy var alertService = AlertService()
    public lazy var notificationService = NotificationService()
    public lazy var weatherService = WeatherService()
    public lazy var apiClient = APIClient()

    private init() {}
}

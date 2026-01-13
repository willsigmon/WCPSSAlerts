import Foundation
import UserNotifications
import UIKit

@MainActor
public final class NotificationService: NSObject {
    private let center = UNUserNotificationCenter.current()
    private let deduplicationManager: AlertDeduplicationManager

    // MARK: - Notification Categories
    private enum NotificationCategory {
        static let prediction = "PREDICTION_ALERT"
        static let closureAlert = "CLOSURE_ALERT"
    }

    // MARK: - Init
    override init() {
        self.deduplicationManager = DIContainer.shared.deduplicationManager
        super.init()
        setupNotificationCategories()
    }

    init(deduplicationManager: AlertDeduplicationManager) {
        self.deduplicationManager = deduplicationManager
        super.init()
        setupNotificationCategories()
    }

    private func setupNotificationCategories() {
        let viewAction = UNNotificationAction(
            identifier: "VIEW_ACTION",
            title: "View Details",
            options: [.foreground]
        )

        let dismissAction = UNNotificationAction(
            identifier: "DISMISS_ACTION",
            title: "Dismiss",
            options: []
        )

        let predictionCategory = UNNotificationCategory(
            identifier: NotificationCategory.prediction,
            actions: [viewAction, dismissAction],
            intentIdentifiers: []
        )

        let alertCategory = UNNotificationCategory(
            identifier: NotificationCategory.closureAlert,
            actions: [viewAction, dismissAction],
            intentIdentifiers: []
        )

        center.setNotificationCategories([predictionCategory, alertCategory])
    }

    // MARK: - Authorization
    func isAuthorized() async -> Bool {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus == .authorized
    }

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound, .timeSensitive])
            if granted {
                await registerForRemoteNotifications()
                center.delegate = self
            }
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }

    private func registerForRemoteNotifications() async {
        #if !targetEnvironment(simulator)
        UIApplication.shared.registerForRemoteNotifications()
        #endif
    }

    // MARK: - Smart Notification (with deduplication)

    /// Sends a notification for a prediction only if it represents a significant change
    /// Returns true if notification was sent, false if deduplicated
    @discardableResult
    func notifyIfSignificant(
        prediction: ClosurePrediction,
        district: District
    ) async -> Bool {
        // Check if we should notify
        guard deduplicationManager.shouldNotify(for: prediction, district: district) else {
            return false
        }

        // Build notification content
        let title = buildPredictionTitle(prediction: prediction, district: district)
        let body = buildPredictionBody(prediction: prediction)
        let identifier = "prediction-\(district.rawValue)-\(Date().timeIntervalSince1970)"

        do {
            try await sendNotification(
                title: title,
                body: body,
                identifier: identifier,
                category: NotificationCategory.prediction,
                userInfo: [
                    "district": district.rawValue,
                    "probability": prediction.probability,
                    "status": prediction.recommendation.rawValue
                ]
            )

            // Record that we sent this notification
            deduplicationManager.recordNotification(for: prediction, district: district)
            return true
        } catch {
            print("Failed to send prediction notification: \(error)")
            return false
        }
    }

    /// Sends a notification for a closure alert only if not already notified
    /// Returns true if notification was sent, false if deduplicated
    @discardableResult
    func notifyIfNew(alert: ClosureAlert) async -> Bool {
        // Check if already notified
        guard !deduplicationManager.hasNotified(alertId: alert.id) else {
            return false
        }

        let identifier = "alert-\(alert.id)"

        do {
            try await sendNotification(
                title: alert.title,
                body: alert.description,
                identifier: identifier,
                category: NotificationCategory.closureAlert,
                userInfo: [
                    "alertId": alert.id,
                    "district": alert.district.rawValue,
                    "status": alert.status.rawValue
                ]
            )

            // Record that we sent this notification
            deduplicationManager.recordAlertNotification(alertId: alert.id)
            return true
        } catch {
            print("Failed to send alert notification: \(error)")
            return false
        }
    }

    // MARK: - Notification Content Builders

    private func buildPredictionTitle(prediction: ClosurePrediction, district: District) -> String {
        switch prediction.recommendation {
        case .closed:
            return "\(district.abbreviation): School Closure Likely"
        case .delay2hr, .delay3hr:
            return "\(district.abbreviation): Delay Expected"
        case .eLearning:
            return "\(district.abbreviation): Remote Learning Likely"
        case .earlyRelease:
            return "\(district.abbreviation): Early Release Possible"
        case .open:
            if prediction.probability >= 40 {
                return "\(district.abbreviation): Weather Alert"
            }
            return "\(district.abbreviation): Status Update"
        }
    }

    private func buildPredictionBody(prediction: ClosurePrediction) -> String {
        let statusText = prediction.recommendation.displayName
        let probabilityText = "\(prediction.probability)% likelihood"

        if prediction.recommendation == .open && prediction.probability < 40 {
            return "Schools expected to remain open. \(probabilityText) of closure."
        }

        return "\(statusText) - \(probabilityText). \(prediction.confidence.displayName) confidence."
    }

    // MARK: - Core Notification Sending

    private func sendNotification(
        title: String,
        body: String,
        identifier: String,
        category: String,
        userInfo: [String: Any] = [:]
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.interruptionLevel = .timeSensitive
        content.categoryIdentifier = category
        content.userInfo = userInfo

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: nil // Deliver immediately
        )

        try await center.add(request)
    }

    // MARK: - Local Notifications (Legacy API)
    func scheduleLocalNotification(
        title: String,
        body: String,
        identifier: String,
        trigger: UNNotificationTrigger? = nil
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.interruptionLevel = .timeSensitive

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        try await center.add(request)
    }

    func cancelNotification(identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        center.removeDeliveredNotifications(withIdentifiers: [identifier])
    }

    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }

    // MARK: - Badge
    func updateBadge(count: Int) async {
        do {
            try await center.setBadgeCount(count)
        } catch {
            print("Failed to update badge: \(error)")
        }
    }

    func clearBadge() async {
        await updateBadge(count: 0)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    /// Handle notification when app is in foreground
    nonisolated public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        // Show notification even when app is in foreground
        return [.banner, .sound, .badge]
    }

    /// Handle notification tap/action
    nonisolated public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo

        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier, "VIEW_ACTION":
            // User tapped notification or view action - handle navigation
            await handleNotificationTap(userInfo: userInfo)

        case "DISMISS_ACTION":
            // User dismissed - no action needed
            break

        default:
            break
        }
    }

    @MainActor
    private func handleNotificationTap(userInfo: [AnyHashable: Any]) {
        // Post notification for app to handle navigation
        NotificationCenter.default.post(
            name: .didTapClosureNotification,
            object: nil,
            userInfo: userInfo as? [String: Any]
        )
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let didTapClosureNotification = Notification.Name("didTapClosureNotification")
}

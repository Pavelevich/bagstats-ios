import Foundation
import UserNotifications

class NotificationService: ObservableObject {
    static let shared = NotificationService()

    @Published var deviceToken: String?
    @Published var isRegistered: Bool = false

    // Backend URL - change this to your server
    #if DEBUG
    private let backendURL = "http://localhost:3001"
    #else
    private let backendURL = "https://api.bagstats.xyz"
    #endif

    private init() {}

    // MARK: - Device Token Registration

    func registerDeviceToken(_ token: String) async {
        self.deviceToken = token

        // Get all wallets from store and register each
        // This will be called when wallets are added/removed
    }

    func subscribeWallet(_ wallet: String) async throws {
        guard let token = deviceToken else {
            throw NotificationError.noDeviceToken
        }

        let url = URL(string: "\(backendURL)/api/subscriptions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "deviceToken": token,
            "wallet": wallet,
            "platform": "ios"
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            throw NotificationError.registrationFailed
        }

        isRegistered = true
    }

    func unsubscribeWallet(_ wallet: String) async throws {
        guard let token = deviceToken else {
            throw NotificationError.noDeviceToken
        }

        let url = URL(string: "\(backendURL)/api/subscriptions/\(wallet)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(token, forHTTPHeaderField: "X-Device-Token")

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 || httpResponse.statusCode == 204 else {
            throw NotificationError.unsubscribeFailed
        }
    }

    // MARK: - Permission Handling

    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }

    func checkPermissionStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Local Notifications (for testing)

    func sendLocalNotification(title: String, body: String, wallet: String? = nil) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        if let wallet = wallet {
            content.userInfo = ["wallet": wallet]
        }

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Demo Mode (for video demos)

    func sendDemoNotification(wallet: String, tokenSymbol: String = "SOL", amountSOL: Double = 0.5, amountUSD: Double = 125.00) {
        let content = UNMutableNotificationContent()
        content.title = "New Bag Received! 💰"
        content.body = "+\(String(format: "%.4f", amountSOL)) SOL (~$\(String(format: "%.2f", amountUSD))) from \(tokenSymbol)"
        content.sound = .default
        content.userInfo = [
            "type": "new_bag",
            "wallet": wallet,
            "tokenSymbol": tokenSymbol,
            "amountSOL": amountSOL,
            "amountUSD": amountUSD
        ]

        // Trigger after 3 seconds so you have time to see the notification banner
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)

        let request = UNNotificationRequest(
            identifier: "demo-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func triggerDemoFromServer(wallet: String) async {
        // Queue notification on server (for demo video)
        guard let url = URL(string: "\(backendURL)/api/demo/queue") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "wallet": wallet,
            "tokenSymbol": "BONK",
            "amountSOL": 0.1847,
            "amountUSD": 46.18
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (_, _) = try await URLSession.shared.data(for: request)
        } catch {
            print("Failed to queue demo: \(error)")
        }
    }

    func checkForDemoNotification(wallet: String) async {
        guard let url = URL(string: "\(backendURL)/api/demo/check/\(wallet)") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            struct DemoResponse: Codable {
                let pending: Bool
                let notification: DemoNotification?
            }

            struct DemoNotification: Codable {
                let title: String
                let body: String
                let wallet: String
                let tokenSymbol: String
                let amountSOL: Double
                let amountUSD: Double
            }

            let response = try JSONDecoder().decode(DemoResponse.self, from: data)

            if response.pending, let notif = response.notification {
                await MainActor.run {
                    sendLocalNotification(
                        title: notif.title,
                        body: notif.body,
                        wallet: notif.wallet
                    )
                }
            }
        } catch {
            print("Failed to check demo: \(error)")
        }
    }
}

enum NotificationError: LocalizedError {
    case noDeviceToken
    case registrationFailed
    case unsubscribeFailed
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .noDeviceToken:
            return "No device token available. Please enable notifications."
        case .registrationFailed:
            return "Failed to register for notifications."
        case .unsubscribeFailed:
            return "Failed to unsubscribe from notifications."
        case .permissionDenied:
            return "Notification permission denied."
        }
    }
}

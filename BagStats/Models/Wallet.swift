import Foundation

struct Wallet: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let address: String
    var name: String?
    var avatarData: Data?
    var notificationsEnabled: Bool
    let createdAt: Date

    init(address: String, name: String? = nil, avatarData: Data? = nil, notificationsEnabled: Bool = true) {
        self.id = UUID()
        self.address = address
        self.name = name
        self.avatarData = avatarData
        self.notificationsEnabled = notificationsEnabled
        self.createdAt = Date()
    }

    var displayName: String {
        name ?? shortAddress
    }

    var shortAddress: String {
        guard address.count > 8 else { return address }
        return "\(address.prefix(4))...\(address.suffix(4))"
    }
}

struct WalletStats: Codable {
    let totalEarned: Double
    let unclaimedFees: Double
    let claimedFees: Double
    let tokensCount: Int
    let positionsCount: Int

    var totalEarnedFormatted: String {
        formatUSD(totalEarned)
    }

    var unclaimedFormatted: String {
        formatUSD(unclaimedFees)
    }

    var claimedFormatted: String {
        formatUSD(claimedFees)
    }

    private func formatUSD(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}

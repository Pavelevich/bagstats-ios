import Foundation

// MARK: - API Response Models

struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let response: T?
    let error: String?
}

struct ClaimablePosition: Codable, Identifiable {
    let programId: String
    let isCustomFeeVault: Bool
    let user: String
    let baseMint: String
    let quoteMint: String
    let isMigrated: Bool
    let userBps: Int
    let virtualPool: String
    let virtualPoolClaimableLamportsUserShare: Int
    let totalClaimableLamportsUserShare: Int

    var id: String { baseMint }

    // Convert lamports to SOL
    var claimableSol: Double {
        Double(totalClaimableLamportsUserShare) / 1_000_000_000.0
    }
}

struct ClaimablePositionsResponse: Codable {
    let positions: [ClaimablePosition]

    enum CodingKeys: String, CodingKey {
        case positions
    }

    init(from decoder: Decoder) throws {
        // The API returns an array directly
        let container = try decoder.singleValueContainer()
        positions = try container.decode([ClaimablePosition].self)
    }
}

struct TokenMetadata: Codable, Identifiable {
    let address: String
    let symbol: String
    let name: String
    let logoURI: String?
    let decimals: Int?

    var id: String { address }
}

struct TokenWithFees: Identifiable {
    let id: String
    let mint: String
    let name: String
    let symbol: String
    let logoURL: String?
    let unclaimedLamports: Int
    let claimedUSD: Double
    let totalFeesUSD: Double

    var unclaimedSOL: Double {
        Double(unclaimedLamports) / 1_000_000_000.0
    }
}

// MARK: - Notification Models

struct BagNotification: Codable, Identifiable {
    let id: UUID
    let wallet: String
    let tokenMint: String
    let tokenSymbol: String
    let amount: Double
    let amountUSD: Double
    let type: NotificationType
    let timestamp: Date

    enum NotificationType: String, Codable {
        case newBag = "new_bag"
        case claimReady = "claim_ready"
        case dailySummary = "daily_summary"
    }
}

struct NotificationPayload: Codable {
    let aps: APS
    let wallet: String?
    let tokenMint: String?
    let amount: Double?

    struct APS: Codable {
        let alert: Alert
        let sound: String?
        let badge: Int?

        struct Alert: Codable {
            let title: String
            let body: String
        }
    }
}

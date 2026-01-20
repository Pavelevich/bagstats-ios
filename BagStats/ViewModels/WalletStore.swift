import Foundation
import SwiftUI

@MainActor
class WalletStore: ObservableObject {
    @Published var wallets: [Wallet] = []
    @Published var walletStats: [String: WalletStats] = [:]
    @Published var isLoading: Bool = false
    @Published var error: String?

    private let storageKey = "bagstats_wallets"
    private let api = BagsAPIService.shared

    init() {
        loadWallets()
        // Auto-refresh stats on launch
        Task {
            await refreshAllStats()
        }
    }

    // MARK: - Wallet Management

    func addWallet(address: String, name: String? = nil) async {
        // Validate address (basic check for Solana address length)
        guard address.count >= 32 && address.count <= 44 else {
            error = "Invalid Solana address"
            return
        }

        // Check for duplicate
        guard !wallets.contains(where: { $0.address == address }) else {
            error = "Wallet already added"
            return
        }

        let wallet = Wallet(address: address, name: name)
        wallets.append(wallet)
        saveWallets()

        // Subscribe to notifications
        do {
            try await NotificationService.shared.subscribeWallet(address)
        } catch {
            print("Failed to subscribe: \(error)")
        }

        // Fetch stats
        await refreshWalletStats(for: address)
    }

    func removeWallet(_ wallet: Wallet) async {
        wallets.removeAll { $0.id == wallet.id }
        walletStats.removeValue(forKey: wallet.address)
        saveWallets()

        // Unsubscribe from notifications
        do {
            try await NotificationService.shared.unsubscribeWallet(wallet.address)
        } catch {
            print("Failed to unsubscribe: \(error)")
        }
    }

    func updateWallet(_ wallet: Wallet) {
        if let index = wallets.firstIndex(where: { $0.id == wallet.id }) {
            wallets[index] = wallet
            saveWallets()
        }
    }

    // MARK: - Stats

    func refreshAllStats() async {
        isLoading = true
        error = nil

        for wallet in wallets {
            await refreshWalletStats(for: wallet.address)
        }

        isLoading = false
    }

    func refreshWalletStats(for address: String) async {
        print("🔄 Fetching stats for \(address)...")
        do {
            let stats = try await api.getWalletStats(wallet: address)
            print("✅ Got stats: \(stats.positionsCount) positions, $\(stats.unclaimedFees)")
            walletStats[address] = stats
        } catch {
            print("❌ Failed to fetch stats for \(address): \(error)")
            self.error = error.localizedDescription
        }
    }

    // MARK: - Aggregated Stats

    var totalStats: WalletStats {
        let total = walletStats.values.reduce(into: (earned: 0.0, unclaimed: 0.0, claimed: 0.0, tokens: 0, positions: 0)) { result, stats in
            result.earned += stats.totalEarned
            result.unclaimed += stats.unclaimedFees
            result.claimed += stats.claimedFees
            result.tokens += stats.tokensCount
            result.positions += stats.positionsCount
        }

        return WalletStats(
            totalEarned: total.earned,
            unclaimedFees: total.unclaimed,
            claimedFees: total.claimed,
            tokensCount: total.tokens,
            positionsCount: total.positions
        )
    }

    // MARK: - Persistence

    private func saveWallets() {
        if let data = try? JSONEncoder().encode(wallets) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadWallets() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Wallet].self, from: data) {
            wallets = decoded
        }
    }
}

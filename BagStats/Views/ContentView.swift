import SwiftUI
import UIKit

// MARK: - Haptics

struct Haptics {
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}

// MARK: - Content View

struct ContentView: View {
    @EnvironmentObject var walletStore: WalletStore
    @State private var selectedTab = 0
    @State private var selectedWalletAddress: String?

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppTheme.background)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                WalletListView(selectedWallet: $selectedWalletAddress)
            }
            .tabItem {
                Label("Wallets", systemImage: "wallet.pass")
            }
            .tag(0)

            NavigationStack {
                SummaryView()
            }
            .tabItem {
                Label("Summary", systemImage: "chart.bar.fill")
            }
            .tag(1)

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(2)
        }
        .tint(AppTheme.primary)
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
        .onChange(of: selectedTab) { _, _ in
            Haptics.selection()
        }
        .onReceive(NotificationCenter.default.publisher(for: .openWallet)) { notification in
            if let address = notification.object as? String {
                selectedWalletAddress = address
                selectedTab = 0
            }
        }
    }
}

// MARK: - Summary View

struct SummaryView: View {
    @EnvironmentObject var walletStore: WalletStore

    private var unclaimedPercent: Double {
        let total = walletStore.totalStats.totalEarned
        guard total > 0 else { return 0 }
        return walletStore.totalStats.unclaimedFees / total
    }

    var body: some View {
        ZStack(alignment: .top) {
            AppBackgroundView()

            if walletStore.wallets.isEmpty {
                EmptySummaryView()
            } else {
                VStack(spacing: 0) {
                    // Header - outside ScrollView like Wallets
                    HStack {
                        Text("Summary")
                            .font(.appTitle(32))
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 20)

                    ScrollView {
                        VStack(spacing: 24) {
                            // Main Card - Unclaimed Focus
                            VStack(spacing: 24) {
                            // Unclaimed (the important number)
                            VStack(spacing: 8) {
                                Text("Ready to Claim")
                                    .font(.appCaption(12))
                                    .foregroundColor(AppTheme.textSecondary)
                                    .textCase(.uppercase)
                                    .tracking(1)

                                Text(walletStore.totalStats.unclaimedFormatted)
                                    .font(.appLargeNumber(52))
                                    .foregroundStyle(AppTheme.primaryGradient)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                            }

                            // Progress bar
                            VStack(spacing: 8) {
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        // Background
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(AppTheme.textMuted.opacity(0.3))
                                            .frame(height: 8)

                                        // Unclaimed portion
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(AppTheme.primaryGradient)
                                            .frame(width: geo.size.width * unclaimedPercent, height: 8)
                                    }
                                }
                                .frame(height: 8)

                                HStack {
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(AppTheme.primary)
                                            .frame(width: 8, height: 8)
                                        Text("Unclaimed")
                                            .font(.appCaption(11))
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                    Spacer()
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(AppTheme.textMuted.opacity(0.5))
                                            .frame(width: 8, height: 8)
                                        Text("Claimed \(walletStore.totalStats.claimedFormatted)")
                                            .font(.appCaption(11))
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                }
                            }
                            .padding(.horizontal, 4)

                            // Quick stats row
                            HStack(spacing: 0) {
                                QuickStat(value: "\(walletStore.wallets.count)", label: "Wallets")

                                Rectangle()
                                    .fill(AppTheme.textMuted.opacity(0.3))
                                    .frame(width: 1, height: 32)

                                QuickStat(value: "\(walletStore.totalStats.positionsCount)", label: "Positions")

                                Rectangle()
                                    .fill(AppTheme.textMuted.opacity(0.3))
                                    .frame(width: 1, height: 32)

                                QuickStat(value: "\(walletStore.totalStats.tokensCount)", label: "Tokens")
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(AppTheme.surface)
                        )
                        .padding(.horizontal, 20)

                        // Wallet breakdown
                        if walletStore.wallets.count > 0 {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("By Wallet")
                                        .font(.appHeadline(15))
                                        .foregroundColor(AppTheme.textSecondary)
                                    Spacer()
                                }
                                .padding(.horizontal, 20)

                                ForEach(walletStore.wallets.sorted { w1, w2 in
                                    let s1 = walletStore.walletStats[w1.address]?.unclaimedFees ?? 0
                                    let s2 = walletStore.walletStats[w2.address]?.unclaimedFees ?? 0
                                    return s1 > s2
                                }) { wallet in
                                    if let stats = walletStore.walletStats[wallet.address] {
                                        WalletSummaryRow(wallet: wallet, stats: stats)
                                    }
                                }
                            }
                        }

                        // Claim button
                        Button {
                            Haptics.impact(.medium)
                            if let url = URL(string: "https://bags.fm") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Claim on Bags.fm")
                                    .font(.appHeadline(16))
                            }
                            .foregroundColor(AppTheme.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppTheme.primaryGradient)
                            .cornerRadius(14)
                            .shadow(color: AppTheme.primary.opacity(0.5), radius: 12, x: 0, y: 0)
                            .shadow(color: AppTheme.primary.opacity(0.3), radius: 20, x: 0, y: 0)
                        }
                        .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                        .padding(.vertical)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.3), value: walletStore.wallets.count)
        .refreshable {
            Haptics.impact(.light)
            await walletStore.refreshAllStats()
        }
    }
}

struct QuickStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.appHeadline(20))
                .foregroundColor(AppTheme.textPrimary)
            Text(label)
                .font(.appCaption(11))
                .foregroundColor(AppTheme.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

struct EmptySummaryView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.primaryGradient)

            Text("No Data Yet")
                .font(.appTitle(24))
                .foregroundColor(AppTheme.textPrimary)

            Text("Add a wallet to see your\nearnings summary")
                .font(.appBody(15))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

struct WalletSummaryRow: View {
    let wallet: Wallet
    let stats: WalletStats

    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            WalletAvatar(wallet: wallet, size: 52)

            // Name
            VStack(alignment: .leading, spacing: 4) {
                Text(wallet.displayName)
                    .font(.appHeadline(17))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(wallet.shortAddress)
                    .font(.appMono(12))
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()

            // Amount
            Text(stats.unclaimedFormatted)
                .font(.appHeadline(18))
                .foregroundStyle(AppTheme.primaryGradient)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "16161E").opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.primary.opacity(0.25), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}

#Preview {
    ContentView()
        .environmentObject(WalletStore())
}

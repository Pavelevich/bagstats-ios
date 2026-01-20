import SwiftUI
import UIKit

struct WalletDetailView: View {
    @EnvironmentObject var walletStore: WalletStore
    let wallet: Wallet


    var stats: WalletStats? {
        walletStore.walletStats[wallet.address]
    }

    var body: some View {
        ZStack(alignment: .top) {
            AppBackgroundView()

            VStack(spacing: 20) {
                // Header - Name + Total + Address
                VStack(spacing: 6) {
                    Text(wallet.displayName)
                        .font(.appTitle(24))
                        .foregroundColor(AppTheme.textPrimary)

                    if let stats = stats {
                        Text(stats.totalEarnedFormatted)
                            .font(.appLargeNumber(48))
                            .foregroundStyle(AppTheme.primaryGradient)
                    } else {
                        ProgressView()
                            .tint(AppTheme.primary)
                            .padding(.vertical, 8)
                    }

                    Button {
                        Haptics.tap()
                        UIPasteboard.general.string = wallet.address
                    } label: {
                        HStack(spacing: 4) {
                            Text(wallet.shortAddress)
                                .font(.appMono(13))
                                .foregroundColor(AppTheme.textSecondary)
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.textMuted)
                        }
                    }
                }
                .padding(.top, 20)

                // Stats Grid 2x2
                if let stats = stats {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatBox(title: "Unclaimed", value: stats.unclaimedFormatted, color: AppTheme.primary)
                        StatBox(title: "Claimed", value: stats.claimedFormatted, color: AppTheme.textSecondary)
                        StatBox(title: "Tokens", value: "\(stats.tokensCount)", color: AppTheme.primary)
                        StatBox(title: "Positions", value: "\(stats.positionsCount)", color: AppTheme.textSecondary)
                    }
                    .padding(.horizontal, 20)
                }

                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Stat box for 2x2 grid
struct StatBox: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.appHeadline(18))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(title.uppercased())
                .font(.appCaption(10))
                .foregroundColor(AppTheme.textMuted)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppTheme.surface)
        )
    }
}

// MARK: - Wallet Avatar Component
struct WalletAvatar: View {
    let wallet: Wallet
    let size: CGFloat
    var fallbackLetter: String?
    var customImageData: Data?

    init(wallet: Wallet, size: CGFloat, fallbackLetter: String? = nil, customImageData: Data? = nil) {
        self.wallet = wallet
        self.size = size
        self.fallbackLetter = fallbackLetter
        self.customImageData = customImageData
    }

    var displayLetter: String {
        if let letter = fallbackLetter, !letter.isEmpty {
            return letter.uppercased()
        }
        return wallet.displayName.prefix(1).uppercased()
    }

    var imageData: Data? {
        customImageData ?? wallet.avatarData
    }

    var body: some View {
        Group {
            if let data = imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                fallbackAvatar
            }
        }
    }

    var fallbackAvatar: some View {
        ZStack {
            Circle()
                .fill(AppTheme.primaryGradient)
                .frame(width: size, height: size)

            Text(displayLetter)
                .font(.appTitle(size * 0.4))
                .foregroundColor(AppTheme.background)
        }
    }
}

#Preview {
    NavigationStack {
        WalletDetailView(wallet: Wallet(address: "Ag9CbunGvtQLi4iZxxYbXgASZUfH1SpL2ij9trRZwjDZ", name: "Main Wallet"))
            .environmentObject(WalletStore())
    }
}

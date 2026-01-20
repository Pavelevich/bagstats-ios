import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject var walletStore: WalletStore
    @StateObject private var notificationService = NotificationService.shared
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined

    var body: some View {
        ZStack(alignment: .top) {
            AppBackgroundView()

            VStack(spacing: 0) {
                // Header - outside ScrollView like Wallets
                HStack {
                    Text("Settings")
                        .font(.appTitle(32))
                        .foregroundColor(AppTheme.textPrimary)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)

                ScrollView {
                    VStack(spacing: 20) {
                        // Notification Settings
                        VStack(alignment: .leading, spacing: 12) {
                            Text("NOTIFICATIONS")
                            .font(.appCaption(11))
                            .foregroundColor(AppTheme.textSecondary)
                            .tracking(1)
                            .padding(.horizontal, 20)

                        VStack(spacing: 0) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.primary.opacity(0.15))
                                        .frame(width: 40, height: 40)
                                    Image("SwipeBell")
                                        .resizable()
                                        .renderingMode(.template)
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(AppTheme.primary)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Push Notifications")
                                        .font(.appHeadline(15))
                                        .foregroundColor(AppTheme.textPrimary)
                                    Text("Get alerts for new bags")
                                        .font(.appCaption(12))
                                        .foregroundColor(AppTheme.textSecondary)
                                }

                                Spacer()

                                Text(notificationStatusText)
                                    .font(.appCaption(12))
                                    .foregroundColor(notificationStatus == .authorized ? AppTheme.primary : AppTheme.textMuted)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        Capsule()
                                            .fill(notificationStatus == .authorized ? AppTheme.primary.opacity(0.15) : AppTheme.surface)
                                    )
                            }
                            .padding(16)

                            if notificationStatus == .denied {
                                Divider()
                                    .background(AppTheme.textMuted.opacity(0.3))

                                Button {
                                    Haptics.tap()
                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "gear")
                                            .foregroundColor(AppTheme.primary)
                                        Text("Open Settings to Enable")
                                            .font(.appBody(14))
                                            .foregroundColor(AppTheme.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12))
                                            .foregroundColor(AppTheme.textMuted)
                                    }
                                    .padding(16)
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppTheme.surface)
                        )
                        .padding(.horizontal, 20)
                    }

                    // Device Info
                    if let token = notificationService.deviceToken {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("DEVICE")
                                .font(.appCaption(11))
                                .foregroundColor(AppTheme.textSecondary)
                                .tracking(1)
                                .padding(.horizontal, 20)

                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Device Token")
                                        .font(.appHeadline(14))
                                        .foregroundColor(AppTheme.textPrimary)
                                    Text(String(token.prefix(24)) + "...")
                                        .font(.appMono(11))
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                                Spacer()
                                Button {
                                    Haptics.tap()
                                    UIPasteboard.general.string = token
                                } label: {
                                    Image(systemName: "doc.on.doc")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppTheme.textMuted)
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(AppTheme.surface)
                            )
                            .padding(.horizontal, 20)
                        }
                    }

                    // About
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ABOUT")
                            .font(.appCaption(11))
                            .foregroundColor(AppTheme.textSecondary)
                            .tracking(1)
                            .padding(.horizontal, 20)

                        VStack(spacing: 0) {
                            Link(destination: URL(string: "https://bagstats.xyz")!) {
                                HStack {
                                    Image(systemName: "globe")
                                        .foregroundColor(AppTheme.primary)
                                    Text("BagStats Web")
                                        .font(.appBody(15))
                                        .foregroundColor(AppTheme.textPrimary)
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppTheme.textMuted)
                                }
                                .padding(16)
                            }

                            Divider()
                                .background(AppTheme.textMuted.opacity(0.3))

                            Link(destination: URL(string: "https://bags.fm")!) {
                                HStack {
                                    Image(systemName: "dollarsign.circle")
                                        .foregroundColor(AppTheme.primary)
                                    Text("Bags.fm")
                                        .font(.appBody(15))
                                        .foregroundColor(AppTheme.textPrimary)
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppTheme.textMuted)
                                }
                                .padding(16)
                            }

                            Divider()
                                .background(AppTheme.textMuted.opacity(0.3))

                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(AppTheme.textMuted)
                                Text("Version")
                                    .font(.appBody(15))
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                                Text(appVersion)
                                    .font(.appMono(13))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            .padding(16)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppTheme.surface)
                        )
                        .padding(.horizontal, 20)
                    }

                    // Demo Mode Section (for video demos)
                    #if DEBUG
                    VStack(alignment: .leading, spacing: 12) {
                        Text("DEMO MODE")
                            .font(.appCaption(11))
                            .foregroundColor(AppTheme.textSecondary)
                            .tracking(1)
                            .padding(.horizontal, 20)

                        VStack(spacing: 0) {
                            Button {
                                Haptics.success()
                                // Simulate new bag notification with 3 second delay
                                if let firstWallet = walletStore.wallets.first {
                                    notificationService.sendDemoNotification(
                                        wallet: firstWallet.address,
                                        tokenSymbol: "BONK",
                                        amountSOL: 0.1847,
                                        amountUSD: 46.18
                                    )
                                } else {
                                    notificationService.sendDemoNotification(
                                        wallet: "DemoWallet",
                                        tokenSymbol: "BONK",
                                        amountSOL: 0.1847,
                                        amountUSD: 46.18
                                    )
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "bell.badge.fill")
                                        .foregroundColor(AppTheme.primary)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Demo: New Bag Notification")
                                            .font(.appBody(15))
                                            .foregroundColor(AppTheme.textPrimary)
                                        Text("Appears in 3 seconds")
                                            .font(.appCaption(11))
                                            .foregroundColor(AppTheme.textMuted)
                                    }
                                    Spacer()
                                }
                                .padding(16)
                            }

                            Divider()
                                .background(AppTheme.textMuted.opacity(0.3))

                            Button {
                                Haptics.impact(.heavy)
                                Task {
                                    for wallet in walletStore.wallets {
                                        await walletStore.removeWallet(wallet)
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                    Text("Clear All Wallets")
                                        .font(.appBody(15))
                                        .foregroundColor(.red)
                                    Spacer()
                                }
                                .padding(16)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppTheme.surface)
                        )
                        .padding(.horizontal, 20)
                    }
                    #endif

                    // Developer Credit
                    VStack(spacing: 0) {
                        HStack(spacing: 14) {
                            Image("TetsuoLogo")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Developed by")
                                    .font(.appCaption(11))
                                    .foregroundColor(AppTheme.textMuted)
                                Text("Tetsuo Corp.")
                                    .font(.appHeadline(16))
                                    .foregroundColor(.white)
                            }

                            Spacer()
                        }
                        .padding(16)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "16161E").opacity(0.95))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppTheme.primary.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.3), value: notificationStatus)
        .task {
            notificationStatus = await notificationService.checkPermissionStatus()
        }
    }

    private var notificationStatusText: String {
        switch notificationStatus {
        case .authorized:
            return "Enabled"
        case .denied:
            return "Disabled"
        case .provisional:
            return "Provisional"
        case .ephemeral:
            return "Ephemeral"
        case .notDetermined:
            return "Not Set"
        @unknown default:
            return "Unknown"
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(WalletStore())
    }
}

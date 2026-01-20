import SwiftUI

struct AddWalletView: View {
    @EnvironmentObject var walletStore: WalletStore
    @Environment(\.dismiss) private var dismiss

    @State private var address = ""
    @State private var name = ""
    @State private var isLoading = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(hex: "050508").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Image("AppIconImage")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 18))

                            Text("Add Wallet")
                                .font(.appTitle(28))
                                .foregroundColor(AppTheme.textPrimary)

                            Text("Track your Bags.fm earnings")
                                .font(.appBody(15))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .padding(.top, 20)

                        // Form Fields
                        VStack(spacing: 16) {
                            // Address Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("WALLET ADDRESS")
                                    .font(.appCaption(11))
                                    .foregroundColor(AppTheme.textSecondary)
                                    .tracking(1)

                                TextField("", text: $address, prompt: Text("Solana wallet address").foregroundColor(AppTheme.textMuted))
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .font(.appMono(14))
                                    .foregroundColor(AppTheme.textPrimary)
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(AppTheme.surface)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(AppTheme.primary.opacity(address.isEmpty ? 0 : 0.3), lineWidth: 1)
                                            )
                                    )
                            }

                            // Name Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("NAME (OPTIONAL)")
                                    .font(.appCaption(11))
                                    .foregroundColor(AppTheme.textSecondary)
                                    .tracking(1)

                                TextField("", text: $name, prompt: Text("e.g. Main Wallet").foregroundColor(AppTheme.textMuted))
                                    .font(.appBody(15))
                                    .foregroundColor(AppTheme.textPrimary)
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(AppTheme.surface)
                                    )
                            }
                        }
                        .padding(.horizontal, 20)

                        // Error Message
                        if let error = error {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(error)
                                    .font(.appCaption(13))
                                    .foregroundColor(.red)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.red.opacity(0.1))
                            )
                            .padding(.horizontal, 20)
                        }

                        // Add Button
                        Button {
                            addWallet()
                        } label: {
                            HStack(spacing: 8) {
                                if isLoading {
                                    ProgressView()
                                        .tint(AppTheme.background)
                                }
                                Text(isLoading ? "Adding..." : "Add Wallet")
                                    .font(.appHeadline(16))
                            }
                            .foregroundColor(AppTheme.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(address.isEmpty ? AppTheme.primary.opacity(0.5) : AppTheme.primary)
                            )
                        }
                        .disabled(address.isEmpty || isLoading)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(AppTheme.surface)
                            .clipShape(Circle())
                    }
                }
            }
        }
    }

    private func addWallet() {
        Haptics.tap()
        isLoading = true
        error = nil

        Task {
            await walletStore.addWallet(
                address: address.trimmingCharacters(in: .whitespacesAndNewlines),
                name: name.isEmpty ? nil : name
            )

            if let storeError = walletStore.error {
                Haptics.error()
                error = storeError
                isLoading = false
            } else {
                Haptics.success()
                dismiss()
            }
        }
    }
}

#Preview {
    AddWalletView()
        .environmentObject(WalletStore())
}

import SwiftUI
import PhotosUI

struct WalletListView: View {
    @EnvironmentObject var walletStore: WalletStore
    @Binding var selectedWallet: String?
    @State private var showingAddWallet = false
    @State private var walletToDelete: Wallet?
    @State private var walletToEdit: Wallet?
    @State private var editedName = ""
    @State private var editedAvatarData: Data?

    var body: some View {
        ZStack(alignment: .top) {
            // Background
            AppBackgroundView()

            VStack(spacing: 0) {
                // Custom Header - aligned title and button
                HStack {
                    Text("Wallets")
                        .font(.appTitle(32))
                        .foregroundColor(AppTheme.textPrimary)

                    Spacer()

                    Button {
                        Haptics.impact(.medium)
                        showingAddWallet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.background)
                            .frame(width: 36, height: 36)
                            .background(AppTheme.primary)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)

                if walletStore.wallets.isEmpty {
                    Spacer()
                    EmptyWalletView(showingAddWallet: $showingAddWallet)
                    Spacer()
                } else {
                    List {
                        ForEach(walletStore.wallets) { wallet in
                            NavigationLink(value: wallet) {
                                WalletRowContent(
                                    wallet: wallet,
                                    stats: walletStore.walletStats[wallet.address]
                                )
                            }
                            .listRowBackground(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(hex: "16161E").opacity(0.95))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(AppTheme.primary.opacity(0.25), lineWidth: 1)
                                    )
                                    .padding(.vertical, 6)
                            )
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                // Remove - red
                                Button(role: .destructive) {
                                    Haptics.impact(.heavy)
                                    walletToDelete = wallet
                                } label: {
                                    Image("SwipeDelete")
                                }

                                // Notifications toggle
                                Button {
                                    Haptics.selection()
                                    var updated = wallet
                                    updated.notificationsEnabled.toggle()
                                    walletStore.updateWallet(updated)
                                } label: {
                                    Image("SwipeBell")
                                }
                                .tint(wallet.notificationsEnabled ? .orange : .purple)

                                // Edit - blue
                                Button {
                                    Haptics.tap()
                                    editedName = wallet.name ?? ""
                                    editedAvatarData = wallet.avatarData
                                    walletToEdit = wallet
                                } label: {
                                    Image("SwipeEdit")
                                }
                                .tint(.blue)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.3), value: walletStore.wallets.count)
        .navigationDestination(for: Wallet.self) { wallet in
            WalletDetailView(wallet: wallet)
        }
        .sheet(isPresented: $showingAddWallet) {
            AddWalletView()
        }
        .refreshable {
            await walletStore.refreshAllStats()
        }
        .onChange(of: selectedWallet) { _, newValue in
            if let address = newValue,
               let _ = walletStore.wallets.first(where: { $0.address == address }) {
                selectedWallet = nil
            }
        }
        .overlay {
            if walletToDelete != nil {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        walletToDelete = nil
                    }

                VStack(spacing: 20) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.15))
                            .frame(width: 60, height: 60)
                        Image("SwipeDelete")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 28, height: 28)
                            .foregroundColor(.red)
                    }

                    // Text
                    VStack(spacing: 8) {
                        Text("Remove Wallet?")
                            .font(.appHeadline(20))
                            .foregroundColor(.white)
                        Text("This will stop tracking this wallet.")
                            .font(.appBody(14))
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    // Buttons
                    HStack(spacing: 12) {
                        Button {
                            Haptics.tap()
                            walletToDelete = nil
                        } label: {
                            Text("Cancel")
                                .font(.appHeadline(15))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AppTheme.surface)
                                )
                        }

                        Button {
                            Haptics.impact(.heavy)
                            if let wallet = walletToDelete {
                                Task {
                                    await walletStore.removeWallet(wallet)
                                }
                            }
                            walletToDelete = nil
                        } label: {
                            Text("Remove")
                                .font(.appHeadline(15))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.red)
                                )
                        }
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "16161E"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 40)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: walletToDelete != nil)
        .sheet(isPresented: Binding(
            get: { walletToEdit != nil },
            set: { if !$0 { walletToEdit = nil } }
        )) {
            if let wallet = walletToEdit {
                EditWalletSheet(
                    wallet: wallet,
                    editedName: $editedName,
                    editedAvatarData: $editedAvatarData
                ) {
                    var updated = wallet
                    updated.name = editedName.isEmpty ? nil : editedName
                    updated.avatarData = editedAvatarData
                    walletStore.updateWallet(updated)
                    Haptics.success()
                    walletToEdit = nil
                }
            }
        }
    }
}

struct WalletRowContent: View {
    let wallet: Wallet
    let stats: WalletStats?

    var body: some View {
        HStack(spacing: 16) {
            // Wallet Avatar
            WalletAvatar(wallet: wallet, size: 52)

            VStack(alignment: .leading, spacing: 4) {
                Text(wallet.displayName)
                    .font(.appHeadline(17))
                    .foregroundColor(.white)

                Text(wallet.shortAddress)
                    .font(.appMono(12))
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()

            if let stats = stats {
                Text(stats.unclaimedFormatted)
                    .font(.appHeadline(18))
                    .foregroundStyle(AppTheme.primaryGradient)
            } else {
                ProgressView()
                    .tint(AppTheme.primary)
            }
        }
        .padding(.vertical, 12)
    }
}

struct EmptyWalletView: View {
    @Binding var showingAddWallet: Bool

    var body: some View {
        VStack(spacing: 24) {
            // App Icon
            Image("AppIconImage")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 22))

            VStack(spacing: 8) {
                Text("No Wallets")
                    .font(.appTitle(24))
                    .foregroundColor(AppTheme.textPrimary)

                Text("Add a Solana wallet to start\ntracking your Bags.fm earnings")
                    .font(.appBody(15))
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                Haptics.impact(.medium)
                showingAddWallet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Add Wallet")
                        .font(.appHeadline(16))
                }
                .foregroundColor(AppTheme.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppTheme.primaryGradient)
                .cornerRadius(14)
            }
            .padding(.horizontal, 40)
        }
        .padding(32)
    }
}

// MARK: - Edit Wallet Sheet
struct EditWalletSheet: View {
    let wallet: Wallet
    @Binding var editedName: String
    @Binding var editedAvatarData: Data?
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Avatar with photo picker
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        ZStack(alignment: .bottomTrailing) {
                            WalletAvatar(
                                wallet: wallet,
                                size: 80,
                                fallbackLetter: editedName.isEmpty ? nil : String(editedName.prefix(1)),
                                customImageData: editedAvatarData
                            )

                            // Camera badge
                            Image(systemName: "camera.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                                .frame(width: 26, height: 26)
                                .background(AppTheme.primary)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(AppTheme.background, lineWidth: 2))
                        }
                }
                .padding(.top, 16)
                .onChange(of: selectedPhoto) { _, newValue in
                    Task {
                        if let data = try? await newValue?.loadTransferable(type: Data.self) {
                            editedAvatarData = data
                        }
                    }
                }

                // Fields
                VStack(spacing: 16) {
                    // Name
                    VStack(alignment: .leading, spacing: 6) {
                        Text("NAME")
                            .font(.appCaption(10))
                            .foregroundColor(AppTheme.textMuted)
                            .tracking(1)

                        TextField("", text: $editedName, prompt: Text("Wallet name").foregroundColor(AppTheme.textMuted))
                            .font(.appBody(15))
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: 10).fill(AppTheme.surface))
                    }

                    // Address (read-only)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ADDRESS")
                            .font(.appCaption(10))
                            .foregroundColor(AppTheme.textMuted)
                            .tracking(1)

                        Button {
                            Haptics.tap()
                            UIPasteboard.general.string = wallet.address
                        } label: {
                            HStack {
                                Text(wallet.address)
                                    .font(.appMono(12))
                                    .foregroundColor(AppTheme.textSecondary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)

                                Spacer()

                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.textMuted)
                            }
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: 10).fill(AppTheme.surface))
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                // Save
                Button {
                    onSave()
                } label: {
                    Text("Save")
                        .font(.appHeadline(16))
                        .foregroundColor(AppTheme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.primaryGradient)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppTheme.textSecondary)
                            .frame(width: 28, height: 28)
                            .background(AppTheme.surface)
                            .clipShape(Circle())
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Edit Wallet")
                        .font(.appHeadline(16))
                        .foregroundColor(AppTheme.textPrimary)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color(hex: "050508"))
    }
}

#Preview {
    NavigationStack {
        WalletListView(selectedWallet: .constant(nil))
            .environmentObject(WalletStore())
    }
}

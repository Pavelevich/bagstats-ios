<p align="center">
  <img src="icon.png" width="120" height="120" alt="BagStats Logo">
</p>

<h1 align="center">BagStats</h1>

<p align="center">
  <strong>Track your Bags.fm earnings on iOS</strong>
</p>

<p align="center">
  <a href="https://developer.apple.com/swift/"><img src="https://img.shields.io/badge/Swift-5.9-orange.svg" alt="Swift 5.9"></a>
  <a href="https://developer.apple.com/ios/"><img src="https://img.shields.io/badge/iOS-17.0+-blue.svg" alt="iOS 17.0+"></a>
  <a href="https://developer.apple.com/xcode/swiftui/"><img src="https://img.shields.io/badge/SwiftUI-5.0-purple.svg" alt="SwiftUI"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg" alt="MIT License"></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS-lightgrey.svg" alt="Platform">
  <img src="https://img.shields.io/badge/Architecture-MVVM-yellow.svg" alt="MVVM">
</p>

---

## Overview

**BagStats** is a native iOS application for monitoring your [Bags.fm](https://bags.fm) earnings on the Solana blockchain. Bags.fm is the leading platform for token creator fees, and BagStats helps you track your unclaimed rewards across multiple wallets in a beautiful, intuitive interface.

## Features

| Feature | Description |
|---------|-------------|
| **Multi-Wallet** | Track unlimited Solana wallets simultaneously |
| **Real-Time Stats** | View unclaimed, claimed, and total earnings |
| **Token Breakdown** | See earnings per token with logos and details |
| **Push Notifications** | Get alerts when new bags arrive *(coming soon)* |
| **Pull to Refresh** | Always see your latest earnings instantly |
| **Custom Avatars** | Personalize wallets with names and photos |
| **Dark Theme** | Beautiful native dark UI with smooth animations |

## Screenshots

<p align="center">
  <i>Coming soon</i>
</p>

## Requirements

| Requirement | Version |
|-------------|---------|
| iOS | 17.0+ |
| Xcode | 15.0+ |
| Swift | 5.9+ |

## Installation

```bash
# Clone the repository
git clone https://github.com/Pavelevich/bagstats-ios.git

# Navigate to project directory
cd bagstats-ios

# Open in Xcode
open BagStats.xcodeproj
```

Build and run on your device or simulator using `Cmd + R`.

## Project Structure

```
BagStats/
├── App/
│   ├── BagStatsApp.swift       # App entry point & delegate
│   └── Theme.swift             # Design system (colors, fonts, styles)
│
├── Models/
│   ├── Wallet.swift            # Wallet data model
│   └── BagPosition.swift       # Position & stats models
│
├── Views/
│   ├── ContentView.swift       # Tab view + Summary screen
│   ├── WalletListView.swift    # Wallet list with swipe actions
│   ├── WalletDetailView.swift  # Individual wallet breakdown
│   ├── AddWalletView.swift     # Add new wallet flow
│   └── SettingsView.swift      # App settings & preferences
│
├── ViewModels/
│   └── WalletStore.swift       # State management & persistence
│
├── Services/
│   ├── BagsAPIService.swift    # API client (async/await)
│   └── NotificationService.swift # Push notification handling
│
└── Resources/
    └── Assets.xcassets         # Images, icons, colors
```

## Architecture

BagStats follows the **MVVM (Model-View-ViewModel)** pattern with modern Swift concurrency:

- **Models** — Pure data structures with Codable conformance
- **Views** — Declarative SwiftUI views with minimal logic
- **ViewModels** — ObservableObject classes handling business logic
- **Services** — Actor-based API clients with async/await

## Tech Stack

| Technology | Purpose |
|------------|---------|
| SwiftUI | Declarative UI framework |
| Swift Concurrency | async/await networking |
| Combine | Reactive state management |
| UserNotifications | Push notification handling |
| PhotosUI | Custom wallet avatars |

## Configuration

The app connects to a backend proxy server that handles API authentication:

```swift
#if DEBUG
private let backendURL = "http://localhost:3001"
#else
private let backendURL = "https://bagstats.xyz"
#endif
```

> **Note:** A backend server is required to proxy requests to the Bags.fm API and manage rate limiting.

## API Endpoints

| Endpoint | Description |
|----------|-------------|
| `GET /api/wallet/:address/stats` | Fetch wallet earnings & positions |
| `POST /api/subscriptions` | Subscribe to push notifications |
| `DELETE /api/subscriptions/:wallet` | Unsubscribe from notifications |

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Roadmap

- [ ] Push notifications for new bags
- [ ] Widget support for home screen
- [ ] Apple Watch companion app
- [ ] Historical earnings charts
- [ ] Multiple currency display (USD/EUR/SOL)

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Bags.fm](https://bags.fm) — Token creator fee platform
- [Solana](https://solana.com) — Blockchain infrastructure
- [Jupiter](https://jup.ag) — Token metadata API

---

<p align="center">
  Made with Swift by <a href="https://github.com/Pavelevich">@Pavelevich</a>
</p>

<p align="center">
  <sub>BagStats is not affiliated with Bags.fm. Use at your own risk.</sub>
</p>

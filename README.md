# BagStats

**Track your Bags.fm earnings on iOS**

BagStats is a native iOS app that lets you monitor your Solana wallet earnings from [Bags.fm](https://bags.fm) - the leading platform for token creator fees on Solana.

## Features

- **Multi-Wallet Support** - Track multiple Solana wallets in one place
- **Real-Time Stats** - View unclaimed fees, claimed amounts, and total earnings
- **Push Notifications** - Get alerts when new bags arrive (coming soon)
- **Beautiful UI** - Native SwiftUI with smooth animations and dark theme
- **Pull to Refresh** - Always see your latest earnings
- **Token Breakdown** - See earnings per token with logos

## Screenshots

| Wallets | Summary | Wallet Detail |
|---------|---------|---------------|
| Track multiple wallets | See total earnings at a glance | Detailed token breakdown |

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/bagstats-ios.git
cd bagstats-ios
```

2. Open the project in Xcode:
```bash
open BagStats.xcodeproj
```

3. Build and run on your device or simulator

## Architecture

```
BagStats/
├── App/
│   ├── BagStatsApp.swift      # App entry point
│   └── Theme.swift            # Colors, fonts, styles
├── Models/
│   ├── Wallet.swift           # Wallet data model
│   └── BagPosition.swift      # Position/stats models
├── Views/
│   ├── ContentView.swift      # Main tab view + Summary
│   ├── WalletListView.swift   # Wallet list with swipe actions
│   ├── WalletDetailView.swift # Individual wallet stats
│   ├── AddWalletView.swift    # Add new wallet
│   └── SettingsView.swift     # App settings
├── ViewModels/
│   └── WalletStore.swift      # State management
├── Services/
│   ├── BagsAPIService.swift   # API client
│   └── NotificationService.swift # Push notifications
└── Resources/
    └── Assets.xcassets        # Images and colors
```

## Tech Stack

- **SwiftUI** - Declarative UI framework
- **Swift Concurrency** - async/await for networking
- **Combine** - Reactive state management
- **UserNotifications** - Push notification handling

## Backend

This app requires a backend server to proxy requests to the Bags.fm API. The backend handles:
- API key management
- Rate limiting
- Push notification delivery (APNs)

Backend repository: [bagstats-backend](https://github.com/yourusername/bagstats-backend) (coming soon)

## Configuration

The app connects to different backend URLs based on build configuration:

```swift
#if DEBUG
private let backendURL = "http://localhost:3001"
#else
private let backendURL = "https://bagstats.xyz"
#endif
```

Update `BagsAPIService.swift` and `NotificationService.swift` with your backend URL for production.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Bags.fm](https://bags.fm) - Token creator fee platform
- [Solana](https://solana.com) - Blockchain infrastructure

## Contact

Developed by **Tetsuo Corp.**

---

*BagStats is not affiliated with Bags.fm. Use at your own risk.*

import Foundation

actor BagsAPIService {
    static let shared = BagsAPIService()

    // Use your backend as proxy (handles API key)
    // Change this to your deployed backend URL for production
    #if DEBUG
    private let backendURL = "http://localhost:3001"
    #else
    private let backendURL = "https://bagstats.xyz"  // Your production URL
    #endif

    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }

    // MARK: - API Methods

    func getWalletStats(wallet: String) async throws -> WalletStats {
        guard let url = URL(string: "\(backendURL)/api/wallet/\(wallet)/stats") else {
            throw BagsAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw BagsAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 429 {
                throw BagsAPIError.rateLimited
            }
            throw BagsAPIError.httpError(httpResponse.statusCode)
        }

        return try JSONDecoder().decode(WalletStats.self, from: data)
    }
}

enum BagsAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case rateLimited
    case apiError(String)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "Server error: \(code)"
        case .rateLimited:
            return "Rate limited. Please try again later."
        case .apiError(let message):
            return message
        case .decodingError:
            return "Failed to decode response"
        }
    }
}

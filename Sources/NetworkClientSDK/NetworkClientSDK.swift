// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public final class NetworkClientSDK: Sendable {
    /// Shared singleton instance of NetworkSDK
    public static let shared = NetworkClientSDK()

    /// Private initializer to enforce singleton pattern
    private init() {}
}

public extension NetworkClientSDK {
    /// Creates a default HTTP client with no interceptors
    @MainActor
    func createClient() -> HTTPClientProtocol {
        return APIClient()
    }

    /// Creates a custom HTTP client with provided interceptors
    @MainActor
    func createClient(
        session: HTTPSessionProtocol = HTTPSession(),
        interceptors: [any HTTPInterceptorProtocol],
        decoder: JSONDecoder = JSONDecoder()
    ) -> HTTPClientProtocol {
        return APIClient(session: session, interceptors: interceptors, decoder: decoder)
    }
}

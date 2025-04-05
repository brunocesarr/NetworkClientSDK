// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

@available(iOS 16, *)
public final class NetworkClient: Sendable {
    /// Shared singleton instance of NetworkClient
    public static let shared = NetworkClient()

    /// Private initializer to enforce singleton pattern
    private init() {}
}

public extension NetworkClient {
    /// Creates a default HTTP client with no interceptors
    func createClient() -> HTTPClientProtocol {
        return APIClient()
    }

    /// Creates a custom HTTP client with provided interceptors
    func createClient(
        session: HTTPSessionProtocol = HTTPSession(),
        interceptors: [any HTTPInterceptorProtocol],
        decoder: JSONDecoder = JSONDecoder()
    ) -> HTTPClientProtocol {
        return APIClient(session: session, interceptors: interceptors, decoder: decoder)
    }
}

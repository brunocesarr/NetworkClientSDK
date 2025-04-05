import Foundation

/// A protocol defining an API client for making network requests.
///
/// `HTTPClientProtocol` provides methods for sending requests to API endpoints and decoding responses.
/// It supports standard requests, void requests, and requests with progress tracking.
///
/// All methods are asynchronous and throw errors if the request fails.
///
/// - Note: Conforming types must be `Sendable` to ensure thread safety.
public protocol HTTPClientProtocol: Sendable {
    var interceptors: [any HTTPInterceptorProtocol] { get }
    var session: HTTPSessionProtocol { get }
    var decoder: JSONDecoder { get }

    /// Sends a request to the specified endpoint and decodes the response into the specified type.
    ///
    /// - Parameters:
    ///   - endpoint: The API endpoint to send the request to.
    ///   - decoder: A `JSONDecoder` instance used for decoding the response. Defaults to `JSONDecoder()`.
    /// - Returns: A decoded instance of type `T`.
    /// - Throws: An error if the request fails or if decoding the response data is unsuccessful.
    /// - Note: The type `T` must conform to `Decodable` and `Sendable`.
    ///
    func request<T: Decodable & Sendable>(
        _ urlRequest: any HTTPRequestProtocol,
        decoder: JSONDecoder
    ) async throws -> T

    /// Sends a request to the specified endpoint and decodes the response into the specified type.
    ///
    /// - Parameters:
    ///   - endpoint: The API endpoint to send the request to.
    ///   - decoder: A `JSONDecoder` instance used for decoding the response. Defaults to `JSONDecoder()`.
    /// - Returns: A decoded instance of type `T`.
    /// - Throws: An error if the request fails or if decoding the response data is unsuccessful.
    /// - Note: The type `T` must conform to `Decodable` and `Sendable`.
    ///
    func request<T: Decodable & Sendable>(
        _ urlRequest: URLRequest,
        decoder: JSONDecoder
    ) async throws -> T

    /// Sends a request that does not return the response body.
    ///
    /// - Parameters:
    ///   - urlRequest: The endpoint to request.
    ///   - decoder: The `JSONDecoder` to use for decoding the response.
    /// - Returns: The decoded response of type `T`.
    /// - Throws: An error if the request fails or if decoding fails.
    /// - This method can be used for various HTTP methods that we are not interested in the response/return value but only if it succeed or fails, such as `POST`, `DELETE`, and `PATCH` and more.
    ///
    func request(
        _ urlRequest: any HTTPRequestProtocol
    ) async throws

    /// Sends a request that does not return the response body.
    ///
    /// - Parameters:
    ///   - urlRequest: The endpoint to request.
    ///   - decoder: The `JSONDecoder` to use for decoding the response.
    /// - Returns: The decoded response of type `T`.
    /// - Throws: An error if the request fails or if decoding fails.
    /// - This method can be used for various HTTP methods that we are not interested in the response/return value but only if it succeed or fails, such as `POST`, `DELETE`, and `PATCH` and more.
    ///
    func request(
        _ urlRequest: URLRequest
    ) async throws
}

public extension HTTPClientProtocol {
    /// Define default `JSONDecoder`
    var decoder: JSONDecoder { JSONDecoder() }

    /// Sends a request to the specified endpoint and decodes the response into the specified type,
    /// using a default `decoder`.
    ///
    /// - Parameter urlRequest: The API endpoint to send the request to.
    /// - Returns: A decoded instance of type `T`.
    /// - Throws: An error if the request fails or if decoding the response data is unsuccessful.
    ///
    func request<T: Decodable & Sendable>(
        _ urlRequest: any HTTPRequestProtocol
    ) async throws -> T {
        try await request(urlRequest, decoder: decoder)
    }

    /// Sends a request to the specified endpoint and decodes the response into the specified type,
    /// using a default `decoder`.
    ///
    /// - Parameter urlRequest: The API endpoint to send the request to.
    /// - Returns: A decoded instance of type `T`.
    /// - Throws: An error if the request fails or if decoding the response data is unsuccessful.
    ///
    func request<T: Decodable & Sendable>(
        _ urlRequest: URLRequest,
    ) async throws -> T {
        try await request(urlRequest, decoder: decoder)
    }
}

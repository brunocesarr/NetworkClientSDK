//
//  APIClient.swift
//  NetworkClientSDK
//
//  Created on 4/1/25.
//

import Foundation

public final class APIClient: HTTPClientProtocol {

    // MARK: - Properties -
    public let session: HTTPSessionProtocol
    public let interceptors: [any HTTPInterceptorProtocol]
    public let decoder: JSONDecoder

    // MARK: - Initialization -
    public init(
        session: HTTPSessionProtocol = HTTPSession(),
        interceptors: [any HTTPInterceptorProtocol] = [],
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.interceptors = interceptors
        self.decoder = decoder
    }
}

// MARK: - URLRequest Methods
public extension APIClient {
    func request<T: Decodable & Sendable>(
        _ urlRequest: URLRequest,
    ) async throws -> T {
        try await request(urlRequest, decoder: decoder)
    }

    func request<T: Decodable & Sendable>(
        _ urlRequest: URLRequest,
        decoder: JSONDecoder
    ) async throws -> T {
        let data = try await performRequest(urlRequest)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw HTTPClientError.decodingFailed(error)
        }
    }

    func request(
        _ urlRequest: URLRequest
    ) async throws {
        try await performRequest(urlRequest)
    }
}

// MARK: - HTTPRequestProtocol Methods
public extension APIClient {
    func request<T: Decodable & Sendable>(
        _ urlRequest: any HTTPRequestProtocol
    ) async throws -> T {
        try await request(urlRequest, decoder: decoder)
    }

    func request<T: Decodable & Sendable>(
        _ urlRequest: any HTTPRequestProtocol,
        decoder: JSONDecoder
    ) async throws -> T {
        guard let urlRequest = urlRequest.urlRequest else {
            throw HTTPClientError.invalidURL
        }

        let data = try await performRequest(urlRequest)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw HTTPClientError.decodingFailed(error)
        }
    }

    func request(
        _ urlRequest: any HTTPRequestProtocol
    ) async throws {
        guard let urlRequest = urlRequest.urlRequest else {
            throw HTTPClientError.invalidURL
        }

        try await performRequest(urlRequest)
    }
}

// MARK: - URLRequestBuilder Methods
public extension APIClient {
    func request<T: Decodable & Sendable>(
        _ urlRequestBuilder: URLRequestBuilder,
    ) async throws -> T {
        try await request(urlRequestBuilder, decoder: decoder)
    }

    func request<T: Decodable & Sendable>(
        _ urlRequestBuilder: URLRequestBuilder,
        decoder: JSONDecoder
    ) async throws -> T {
        let data = try await performRequest(urlRequestBuilder.makeRequest())
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw HTTPClientError.decodingFailed(error)
        }
    }

    func request(
        _ urlRequestBuilder: URLRequestBuilder
    ) async throws {
        try await performRequest(urlRequestBuilder.makeRequest())
    }
}


// MARK: - Private extensions
private extension APIClient {

    @discardableResult
    private func performRequest(
        _ request: URLRequest
    ) async throws -> Data {
        var mutableRequest = request

        // Apply request interceptors
        for interceptor in interceptors {
            mutableRequest = interceptor.intercept(request: mutableRequest)
        }

        // If a progress delegate is provided, create a new session instance.
        let sessionToUse: HTTPSessionProtocol = session

        do {
            let (data, response) = try await sessionToUse.data(for: mutableRequest)

            // Apply response interceptors
            var modifiedData = data
            var modifiedResponse = response
            for interceptor in interceptors {
                let result = interceptor.intercept(response: modifiedResponse, data: modifiedData)
                modifiedResponse = result.0 ?? modifiedResponse
                modifiedData = result.1 ?? modifiedData
            }

            guard let httpResponse = modifiedResponse as? HTTPURLResponse else {
                throw HTTPClientError.invalidResponse(modifiedData)
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw HTTPClientError.statusCode(httpResponse.statusCode)
            }

            return modifiedData
        } catch {
            if let urlError = error as? URLError {
                throw HTTPClientError.networkError(urlError)
            } else {
                throw HTTPClientError.requestFailed(error)
            }
        }
    }
}

// MARK: - Log extension -
private extension APIClient {

    private func log(_ string: String) {
        #if DEBUG
        print(string)
        #endif
    }
}

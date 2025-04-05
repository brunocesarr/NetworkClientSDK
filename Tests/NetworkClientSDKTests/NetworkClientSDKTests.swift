//
//  NetworkClientSDKTests.swift
//  NetworkClientSDKTests
//
//  Created by dtidigital on 4/1/25.
//

import Foundation
import Testing
@testable import NetworkClientSDK

struct MockResponse: Encodable, Decodable {
    let data: String?
}

struct MockRequest: HTTPRequestProtocol {
    var method: HTTPMethod = .get
    var path: String = "/test"
    var baseURL: String = "https://example.com"
    var headers: [String : String] = [:]
    var urlParams: [String : any CustomStringConvertible] = [:]
    var body: HTTPBody? = nil
    var apiVersion: String? = nil
}

@Suite("NetworkClientSDK") class NetworkClientSDKTests {
    @Suite("URLRequest") class URLRequestTests {
        // MARK: - Properties
        var apiClient: APIClient!
        let request: URLRequest = .init(endpointRequest: URLRequestBuilder(basePath: "https://example.com").path("multiple-headers"))

        init() {
            let config = URLSessionConfiguration.ephemeral
            config.protocolClasses = [MockURLProtocol.self]
            let session = HTTPSession(session: URLSession(configuration: config))

            apiClient = APIClient(session: session)
        }

        deinit {
            apiClient = nil
            MockURLProtocol.mockResponse = (nil, nil, nil)
        }

        @Test("Request success with response")
        func requestSuccessWithResponse() async throws {
            let responseData = try JSONEncoder().encode(MockResponse(data: "test"))

            MockURLProtocol.mockResponse = (
                responseData,
                HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil),
                nil
            )
            let result: MockResponse = try await apiClient.request(request)

            #expect(result.data == "test")
        }

        @Test("Request success without response")
        func requestSuccessWithoutResponse() async throws {
            MockURLProtocol.mockResponse = (
                nil,
                HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil),
                nil
            )
            do {
                try await apiClient.request(request)
            } catch {
                #expect(true == false)
            }
        }

        @Test("Request failure")
        func requestFailure() async {
            MockURLProtocol.mockResponse = (nil, nil, URLError(.badServerResponse))

            do {
                try await apiClient.request(request)
            } catch {
                #expect(error is HTTPClientError)
            }
        }
    }

    @Suite("URLRequestBuilder") class URLRequestBuilderTests {
        // MARK: - Properties
        var apiClient: APIClient!
        let request: URLRequestBuilder = URLRequestBuilder(basePath: "https://example.com").path("multiple-headers")

        init() {
            let config = URLSessionConfiguration.ephemeral
            config.protocolClasses = [MockURLProtocol.self]
            let session = HTTPSession(session: URLSession(configuration: config))

            apiClient = APIClient(session: session)
        }

        deinit {
            apiClient = nil
            MockURLProtocol.mockResponse = (nil, nil, nil)
        }

        @Test("Request success with response")
        func requestSuccessWithResponse() async throws {
            let responseData = try JSONEncoder().encode(MockResponse(data: "test"))

            MockURLProtocol.mockResponse = (
                responseData,
                HTTPURLResponse(url: request.makeRequest().url!, statusCode: 200, httpVersion: nil, headerFields: nil),
                nil
            )
            let result: MockResponse = try await apiClient.request(request)

            #expect(result.data == "test")
        }

        @Test("Request success without response")
        func requestSuccessWithoutResponse() async throws {
            MockURLProtocol.mockResponse = (
                nil,
                HTTPURLResponse(url: request.makeRequest().url!, statusCode: 200, httpVersion: nil, headerFields: nil),
                nil
            )
            do {
                try await apiClient.request(request)
            } catch {
                #expect(true == false)
            }
        }

        @Test("Request failure")
        func requestFailure() async {
            MockURLProtocol.mockResponse = (nil, nil, URLError(.badServerResponse))

            do {
                try await apiClient.request(request)
            } catch {
                #expect(error is HTTPClientError)
            }
        }
    }

    @Suite("HTTPRequestProtocol") class HTTPRequestProtocolTests {
        // MARK: - Properties
        var apiClient: APIClient!
        let request: MockRequest = .init()

        init() {
            let config = URLSessionConfiguration.ephemeral
            config.protocolClasses = [MockURLProtocol.self]
            let session = HTTPSession(session: URLSession(configuration: config))

            apiClient = APIClient(session: session)
        }

        deinit {
            apiClient = nil
            MockURLProtocol.mockResponse = (nil, nil, nil)
        }

        @Test("Request success with response")
        func requestSuccessWithResponse() async throws {
            let responseData = try JSONEncoder().encode(MockResponse(data: "test"))

            MockURLProtocol.mockResponse = (
                responseData,
                HTTPURLResponse(url: request.urlRequest!.url!, statusCode: 200, httpVersion: nil, headerFields: nil),
                nil
            )
            let result: MockResponse = try await apiClient.request(request)

            #expect(result.data == "test")
        }

        @Test("Request success without response")
        func requestSuccessWithoutResponse() async throws {
            MockURLProtocol.mockResponse = (
                nil,
                HTTPURLResponse(url: request.urlRequest!.url!, statusCode: 200, httpVersion: nil, headerFields: nil),
                nil
            )
            do {
                try await apiClient.request(request)
            } catch {
                #expect(true == false)
            }
        }

        @Test("Request failure")
        func requestFailure() async {
            MockURLProtocol.mockResponse = (nil, nil, URLError(.badServerResponse))

            do {
                try await apiClient.request(request)
            } catch {
                #expect(error is HTTPClientError)
            }
        }
    }
}

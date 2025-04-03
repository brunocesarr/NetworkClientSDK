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

@Suite("NetworkClientSDK") class NetworkClientSDKTests {
    // MARK: - Properties
    var apiClient: APIClient!
    let request = URLRequestBuilder(path: "multiple-headers")
        .makeRequest(withBaseURL: URL(string: "https://example.com")!)

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

    @Test func requestSuccessWithResponse() async throws {
        let responseData = try JSONEncoder().encode(MockResponse(data: "test"))

        MockURLProtocol.mockResponse = (
            responseData,
            HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil),
            nil
        )
        let result: MockResponse = try await apiClient.request(request)

        #expect(result.data == "test")
    }

    @Test func requestSuccessWithoutResponse() async throws {
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

    @Test func requestFailure() async {
        MockURLProtocol.mockResponse = (nil, nil, URLError(.badServerResponse))

        do {
            try await apiClient.request(request)
        } catch {
            #expect(error is HTTPClientError)
        }
    }
}

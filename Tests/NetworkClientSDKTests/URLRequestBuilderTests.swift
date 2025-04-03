//
//  URLRequestBuilderTests.swift
//  NetworkClientSDK
//
//  Created by dtidigital on 4/3/25.
//

import Foundation
import Testing
@testable import NetworkClientSDK

@Suite("URLRequestBuilder") class URLRequestBuilderTests {
    let testURL = URL(string: "https://example.com")!

    @Test func multipleHeaders() async throws {
        let request = URLRequestBuilder(path: "multiple-headers")
            .header(name: HTTPHeaderName.accept, values: ["A", "B", "C"])
            .makeRequest(withBaseURL: testURL)

        #expect(request.value(forHTTPHeaderField: HTTPHeaderName.accept.rawValue) == "A,B,C")
    }

    @Test func builder() async throws {
        let user = 1
        let userData = try JSONEncoder().encode(user)
        let authToken = "aaa"

        let request = try URLRequestBuilder(path: "users/submit")
            .method(.post)
            .jsonBody(user)
            .contentType(.applicationJSON)
            .accept(.applicationJSON)
            .timeout(20)
            .queryItem(name: "city", value: "San Francisco")
            .header(name: HTTPHeaderName.authorization, value: authToken)
            .makeRequest(withBaseURL: testURL)

        #expect(request.url?.absoluteString == "https://example.com/users/submit?city=San%20Francisco")
        #expect(request.value(forHTTPHeaderField: HTTPHeaderName.authorization.rawValue) == authToken)
        #expect(request.value(forHTTPHeaderField: HTTPHeaderName.contentType.rawValue) == HTTPContentType.applicationJSON.rawValue)
        #expect(request.value(forHTTPHeaderField: HTTPHeaderName.accept.rawValue) == HTTPContentType.applicationJSON.rawValue)
        #expect(request.httpMethod == HTTPMethod.post.rawValue)
        #expect(request.httpBody == userData)
    }
}

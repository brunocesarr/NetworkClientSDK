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

    @Test("Multiple headers")
    func multipleHeaders() async throws {
        let request = URLRequestBuilder(basePath: "https://example.com")
            .path("multiple-headers")
            .header(name: HTTPHeaderName.accept, values: ["A", "B", "C"])
            .makeRequest()

        #expect(request.value(forHTTPHeaderField: HTTPHeaderName.accept.rawValue) == "A,B,C")
    }

    @Test("Builder")
    func builder() async throws {
        let user = 1
        let userData = try JSONEncoder().encode(user)
        let authToken = "aaa"

        let request = URLRequestBuilder(basePath: "https://example.com")
            .path("users/submit")
            .method(.post)
            .body(userData)
            .contentType(.applicationJSON)
            .accept(.applicationJSON)
            .timeout(20)
            .queryItem(name: "city", value: "San Francisco")
            .header(name: HTTPHeaderName.authorization, value: authToken)
            .makeRequest()

        #expect(request.url?.absoluteString == "https://example.com/users/submit?city=San%20Francisco")
        #expect(request.value(forHTTPHeaderField: HTTPHeaderName.authorization.rawValue) == authToken)
        #expect(request.value(forHTTPHeaderField: HTTPHeaderName.contentType.rawValue) == HTTPContentType.applicationJSON.rawValue)
        #expect(request.value(forHTTPHeaderField: HTTPHeaderName.accept.rawValue) == HTTPContentType.applicationJSON.rawValue)
        #expect(request.httpMethod == HTTPMethod.post.rawValue)
        #expect(request.httpBody == userData)
    }

    @Test("Builder with slashes")
    func builderWithSlashes() async throws {
        let request = URLRequestBuilder(basePath: "https://example.com/")
            .path("/users/submit/")
            .makeRequest()

        #expect(request.url?.absoluteString == "https://example.com/users/submit")
    }
}

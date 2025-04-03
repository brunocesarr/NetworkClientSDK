//
//  URLRequestBuilder.swift
//  NetworkClientSDK
//
//  Created by dtidigital on 4/3/25.
//

import Foundation

public struct URLRequestBuilder {
    public private(set) var buildURLRequest: (inout URLRequest) -> Void
    public private(set) var urlComponents: URLComponents
    public private(set) var encoder: JSONEncoder

    private init(urlComponents: URLComponents, encoder: JSONEncoder = JSONEncoder()) {
        self.buildURLRequest = { _ in }
        self.urlComponents = urlComponents
        self.encoder = encoder
    }

    // MARK: - Starting point
    public init(path: String, encoder: JSONEncoder = JSONEncoder()) {
        var components = URLComponents()
        components.path = path
        self.init(urlComponents: components, encoder: encoder)
    }
}

// MARK: - Factories
public extension URLRequestBuilder {
    static func get(path: String) -> URLRequestBuilder {
        .init(path: path)
        .method(.get)
    }

    static func post(path: String) -> URLRequestBuilder {
        .init(path: path)
        .method(.post)
    }

    static func delete(path: String) -> URLRequestBuilder {
        .init(path: path)
        .method(.delete)
    }

    static func jsonGet(path: String) -> URLRequestBuilder {
        .get(path: path)
        .contentType(.applicationJSON)
    }

    static func jsonPost(path: String, jsonData: Data) -> URLRequestBuilder {
        .post(path: path)
        .contentType(.applicationJSON)
        .body(jsonData)
    }

    static func jsonPost<Content: Encodable>(path: String, jsonObject: Content) throws -> URLRequestBuilder {
        try .post(path: path)
            .contentType(.applicationJSON)
            .jsonBody(jsonObject)
    }
}

// MARK: - Building Blocks
public extension URLRequestBuilder {
    static func customURL(_ url: URL) -> URLRequestBuilder {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            print("can't make URLComponents from URL")
            return URLRequestBuilder(urlComponents: .init())
        }
        return URLRequestBuilder(
            urlComponents: components
        )
    }

    func modifyRequest(_ modifyRequest: @escaping (inout URLRequest) -> Void) -> URLRequestBuilder {
        var copy = self
        let existing = buildURLRequest
        copy.buildURLRequest = { request in
            existing(&request)
            modifyRequest(&request)
        }
        return copy
    }

    func modifyURL(_ modifyURL: @escaping (inout URLComponents) -> Void) -> URLRequestBuilder {
        var copy = self
        modifyURL(&copy.urlComponents)
        return copy
    }

    func method(_ method: HTTPMethod) -> URLRequestBuilder {
        modifyRequest { $0.httpMethod = method.rawValue }
    }

    func body(_ body: Data, setContentLength: Bool = false) -> URLRequestBuilder {
        let updated = modifyRequest { $0.httpBody = body }
        if setContentLength {
            return updated.contentLength(body.count)
        } else {
            return updated
        }
    }

    func jsonBody<Content: Encodable>(_ body: Content, setContentLength: Bool = false) throws -> URLRequestBuilder {
        let body = try encoder.encode(body)
        return self.body(body)
    }
}

// MARK: - Headers
public extension URLRequestBuilder {
    func contentType(_ contentType: HTTPContentType) -> URLRequestBuilder {
        header(name: HTTPHeaderName.contentType, value: contentType.rawValue)
    }

    func accept(_ contentType: HTTPContentType) -> URLRequestBuilder {
        header(name: HTTPHeaderName.accept, value: contentType.rawValue)
    }

    func contentEncoding(_ encoding: HTTPEncoding) -> URLRequestBuilder {
        header(name: HTTPHeaderName.contentEncodingHeader, value: encoding.rawValue)
    }

    func acceptEncoding(_ encoding: HTTPEncoding) -> URLRequestBuilder {
        header(name: HTTPHeaderName.acceptEncodingHeader, value: encoding.rawValue)
    }

    func contentLength(_ length: Int) -> URLRequestBuilder {
        header(name: HTTPHeaderName.contentLength, value: String(length))
    }

    func header(name: HTTPHeaderName, value: String) -> URLRequestBuilder {
        modifyRequest { $0.addValue(value, forHTTPHeaderField: name.rawValue) }
    }

    func header(name: HTTPHeaderName, values: [String]) -> URLRequestBuilder {
        var copy = self
        for value in values {
            copy = copy.header(name: name, value: value)
        }
        return copy
    }
}

// MARK: - Query Items
public extension URLRequestBuilder {
    func queryItems(_ queryItems: [URLQueryItem]) -> URLRequestBuilder {
        modifyURL { urlComponents in
            var items = urlComponents.queryItems ?? []
            items.append(contentsOf: queryItems)
            urlComponents.queryItems = items
        }
    }

    func queryItems(_ queryItems: KeyValuePairs<String, String>) -> URLRequestBuilder {
        self.queryItems(queryItems.map { .init(name: $0.key, value: $0.value) })
    }

    func queryItem(name: String, value: String) -> URLRequestBuilder {
        queryItems([name: value])
    }
}

// MARK: - Timeout
public extension URLRequestBuilder {
    func timeout(_ timeout: TimeInterval) -> URLRequestBuilder {
        modifyRequest { $0.timeoutInterval = timeout }
    }
}

// MARK: - Finalizing
public extension URLRequestBuilder {
    func makeRequest(withBaseURL baseURL: URL) -> URLRequest {
        makeRequest(withConfig: .baseURL(baseURL))
    }

    func makeRequest(withConfig config: RequestConfiguration) -> URLRequest {
        config.configureRequest(self)
    }
}

// MARK: - RequestConfiguration
public struct RequestConfiguration {
    init(configureRequest: @escaping (URLRequestBuilder) -> URLRequest) {
        self.configureRequest = configureRequest
    }

    let configureRequest: (URLRequestBuilder) -> URLRequest
}

public extension RequestConfiguration {
    static func baseURL(_ baseURL: URL) -> RequestConfiguration {
        return RequestConfiguration { request in
            let finalURL = request.urlComponents.url(relativeTo: baseURL) ?? baseURL

            var urlRequest = URLRequest(url: finalURL)
            request.buildURLRequest(&urlRequest)

            return urlRequest
        }
    }
}

// MARK: - URLRequest
public extension URLRequest {
    init(baseURL: URL, endpointRequest: URLRequestBuilder) {
        self = endpointRequest.makeRequest(withBaseURL: baseURL)
    }
}

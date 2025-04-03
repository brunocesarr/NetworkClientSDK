//
//  HTTPMethod.swift
//  NetworkClientSDK
//
//  Created on 4/1/25.
//

import Foundation

/// Enum defining HTTP methods.
public enum HTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

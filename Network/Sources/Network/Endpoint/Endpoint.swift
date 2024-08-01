//
//  Endpoint.swift
//
//
//  Created by Erick Vicente on 31/07/24.
//

import Foundation

public typealias HTTPHeader = [String: String]

public protocol Endpoint {
    var version: API.Version { get }
    var endpoint: String { get }
    var queries: [URLQueryItem]? { get }
    var body: Data? { get }
    var method: HTTPMethod { get }
    var header: HTTPHeader { get }
}

public extension Endpoint {
    var version: API.Version { .none }
    var queries: [URLQueryItem]? { nil }
    var body: Data? { nil }
    var header: HTTPHeader { [:] }
}


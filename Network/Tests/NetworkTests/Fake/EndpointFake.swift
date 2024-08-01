//
//  EndpointFake.swift
//
//
//  Created by Erick Vicente on 31/07/24.
//

import Foundation
@testable import Network

extension API.Version {
    static var v1: API.Version { API.Version(rawValue: "/v1")! }
}

enum EndpointFake: Endpoint {
    case detail
    case images
    case imagesFiltered(String)

    var version: API.Version { .v1 }

    var endpoint: String {
        switch self {
        case .detail:
            return "/product/detail"
        case .images, .imagesFiltered:
            return "/product/images"
        }
    }

    var queries: [URLQueryItem]? {
        switch self {
        case let .imagesFiltered(param):
            return [URLQueryItem(name: "param", value: param)]
        default:
            return nil
        }
    }

    var body: Data? {
        switch self {
        case .detail:
            return try? JSONEncoder().encode(["param": "test"])
        default:
            return nil
        }
    }

    var method: HTTPMethod {
        switch self {
        case .detail:
            return .post
        case .images, .imagesFiltered:
            return .get
        }
    }

    var header: HTTPHeader { ["header": "test"] }
}


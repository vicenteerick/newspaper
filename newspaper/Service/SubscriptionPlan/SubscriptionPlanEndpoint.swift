//
//  SubscriptionPlanEndpoint.swift
//  newspaper
//
//  Created by Erick Vicente on 31/07/24.
//

import Foundation
import Network

extension API.Version {
    static var v3: API.Version { API.Version(rawValue: "v3")! }
}

enum SubscriptionPlanEndpoint: Endpoint {
    case plan(id: String)

    var endpoint: String {
        switch self {
        case let .plan(id):
            return "/qs/\(id)"
        }
    }

    var method: HTTPMethod { .get }
    var version: API.Version { .v3 }
}


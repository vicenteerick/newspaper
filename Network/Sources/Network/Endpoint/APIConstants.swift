//
//  APIConstants.swift
//
//
//  Created by Erick Vicente on 31/07/24.
//

import Foundation

public enum API {
    public struct Version: RawRepresentable {
        private(set) public var rawValue: String

        public init?(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension API.Version: CustomStringConvertible {
    public var description: String { rawValue }
    public static var none: API.Version { API.Version(rawValue: "")! }
}

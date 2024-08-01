//
//  URLUtil.swift
//
//
//  Created by Erick Vicente on 31/07/24.
//

import Combine
import Foundation

public protocol URLSessionTaskable {
    func dataTaskAnyPublisher(for request: URLRequest
    ) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
}

extension URLSession: URLSessionTaskable {
    public func dataTaskAnyPublisher(for request: URLRequest
    ) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        dataTaskPublisher(for: request).eraseToAnyPublisher()
    }
}

public protocol URLSessionDataTaskCancelable {
    func cancel()
}

extension URLSessionDataTask: URLSessionDataTaskCancelable { }

extension URL {
    init(baseUrl: String, path: String, queries: [URLQueryItem]?) throws {
        guard var components = URLComponents(string: baseUrl) else {
            throw NetworkError.invalidBaseUrl
        }

        components.path += path
        components.queryItems = queries

        guard let url = components.url else {
            throw NetworkError.invalidUrl
        }

        self = url
    }
}

extension URLRequest {
    init(baseUrl: String, setup: Endpoint) throws {
        let path = setup.version.rawValue + setup.endpoint
        let url = try URL(baseUrl: baseUrl, path: path, queries: setup.queries)

        var urlRequest = URLRequest(url: url)

        if let body = setup.body {
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = body
        }

        urlRequest.httpMethod = setup.method.rawValue

        setup.header.forEach { key, value in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }

        self = urlRequest
    }

    var description: String {
        var textDescription = ""

        if let headers = allHTTPHeaderFields,
           !headers.isEmpty {
            textDescription += "HEADERS: \(String(describing: headers))\n"
        }

        textDescription += "URL: [\(httpMethod ?? "")] \(url?.absoluteString ?? "")\n"

        if let httpBody = httpBody {
            let body = String(data: httpBody, encoding: .utf8) ?? ""
            textDescription += "BODY: \(body)\n"
        }

        return textDescription
    }
}


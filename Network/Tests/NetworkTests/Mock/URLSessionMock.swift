//
//  URLSessionMock.swift
//
//
//  Created by Erick Vicente on 31/07/24.
//

import Combine
import Foundation
@testable import Network

class URLSessionMock: URLSessionTaskable {
    var data: Data?
    var error: Error?
    var urlResponse: URLResponse?

    init(data: Data?, urlResponse: URLResponse?) {
        self.data = data
        self.urlResponse = urlResponse
    }

    func dataTaskAnyPublisher(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        Just((data: data ?? Data(), response: urlResponse ?? OtherURLResponseMock()))
            .setFailureType(to: URLError.self)
            .eraseToAnyPublisher()
    }
}

class OtherURLResponseMock: URLResponse {
    init() {
        super.init(url: URL(fileURLWithPath: ""), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


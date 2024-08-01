//
//  NetworkClientPublisherTests.swift
//
//
//  Created by Erick Vicente on 31/07/24.
//

import Combine
import Foundation
@testable import Network
import XCTest

final class NetworkClientPublisherTests: XCTestCase {
    var urlSessionMock: URLSessionMock!
    var sut: NetworkClient!
    var endpoint: EndpointFake!

    override func setUp() {
        super.setUp()
        let urlResponse = createUrlResponse(statusCode: 200)
        urlSessionMock = URLSessionMock(data: "".data(using: .utf8), urlResponse: urlResponse)
        sut = NetworkClient(baseUrl: "https://www.test.com", session: urlSessionMock)
        endpoint = EndpointFake.detail
    }

    func testRequest_WhenInvalidURL_ShouldFail() {
        sut = NetworkClient(baseUrl: "http://test.com:-80/", session: urlSessionMock)
        var serviceError: NetworkError?

        let cancellable = sut.request(setup: endpoint).sink { [weak self] completion in
            serviceError = self?.handleRequestFailure(completion: completion)
        } receiveValue: { (_: NoReplyStub) in }

        XCTAssertEqual(serviceError, .invalidBaseUrl)
        XCTAssertNotNil(cancellable)
    }

    func testRequest_WhenIsNotHTTPUrlResponse_ShouldFail() {
        assertFailure(urlResponse: OtherURLResponseMock(),
                      expectedError: .invalidHttpUrlResponse)
    }

    func testRequest_WhenStatusCodeIs401_ShouldFail() {
        assertFailure(urlResponse: createUrlResponse(statusCode: 401),
                      expectedError: .authenticationRequired)
    }

    func testRequest_WhenStatusCodeIs404_ShouldFail() {
        assertFailure(urlResponse: createUrlResponse(statusCode: 404),
                      expectedError: .hostNotFound)
    }

    func testRequest_WhenStatusCodeIs409_ShouldFail() {
        assertFailure(urlResponse: createUrlResponse(statusCode: 409),
                      expectedError: .alreadyExist)
    }

    func testRequest_WhenStatusCodeIs500_ShouldFail() {
        assertFailure(urlResponse: createUrlResponse(statusCode: 500),
                      expectedError: .badRequest)
    }

    func testRequest_WhenAnyStatusCode_AndFailureResponseData_ShouldFail() {
        let data = "{\"codeDescription\": \"10002\", \"message\": \"Some failure\", \"status\": \"200\"}".data(using: .utf8)!
        urlSessionMock.data = data

        assertFailure(urlResponse: createUrlResponse(statusCode: 402),
                      expectedError: .requestFailure(data))
    }

    func testRequest_WhenIsSuccessStatusCode_AndResponseData_ShouldReturnDecodedResponse() {
        urlSessionMock.data = "{\"response\": \"Success\"}".data(using: .utf8)
        var serviceError: NetworkError?
        var response: SuccessStub?
        let expect = expectation(description: "Success")

        let cancellable = sut.request(setup: endpoint)
            .sink { [weak self] completion in
                serviceError = self?.handleRequestFailure(completion: completion)
                expect.fulfill()
            } receiveValue: { (data: SuccessStub) in
                response = data
            }

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertNotNil(response)
        XCTAssertEqual(response?.response, "Success")
        XCTAssertNotNil(cancellable)
        XCTAssertNil(serviceError)
    }

    func testRequest_WhenIsSuccessStatusCode_AndCannotParseData_ToObjectResponse_ShouldFail() {
        urlSessionMock.data = "{\"response\": 10}".data(using: .utf8)
        var serviceError: NetworkError?
        let expect = expectation(description: "Error")

        let cancellable = sut.request(setup: endpoint)
            .mapError { $0 }
            .sink { [weak self] completion in
                serviceError = self?.handleRequestFailure(completion: completion)
                expect.fulfill()
            } receiveValue: { (_: SuccessStub) in }

        waitForExpectations(timeout: 5, handler: nil)

        let expectedError = DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: ""))
        XCTAssertEqual(serviceError, .responseDecondingFailure(expectedError.localizedDescription))
        XCTAssertNotNil(cancellable)
    }

    private func assertFailure(urlResponse: URLResponse?, expectedError: NetworkError) {
        urlSessionMock.urlResponse = urlResponse
        var serviceError: NetworkError?
        let expect = expectation(description: "Error")

        let cancellable = sut.request(setup: endpoint)
            .mapError { $0 }
            .sink { [weak self] completion in
                serviceError = self?.handleRequestFailure(completion: completion)
                expect.fulfill()
            } receiveValue: { (_: NoReplyStub) in }

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(serviceError, expectedError)
        XCTAssertNotNil(cancellable)
    }

    private func createUrlResponse(statusCode: Int = 200) -> HTTPURLResponse? {
        HTTPURLResponse(url: URL(string: "https://www.test.com")!,
                        statusCode: statusCode,
                        httpVersion: nil,
                        headerFields: nil)
    }

    private func handleRequestFailure(completion: Subscribers.Completion<NetworkError>) -> NetworkError? {
        switch completion {
        case let .failure(error):
            return error
        default:
            return nil
        }
    }

    override func tearDown() {
        super.tearDown()

        urlSessionMock = nil
        sut = nil
        endpoint = nil
    }
}


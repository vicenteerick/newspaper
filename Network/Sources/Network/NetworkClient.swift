//
//  NetworkClient.swift
//
//
//  Created by Erick Vicente on 31/07/24.
//

import Foundation
import Combine

public protocol ClientPublishing {
    func request<T: Decodable>(setup: Endpoint) -> AnyPublisher<T, NetworkError>
    func downloadData(url: URL) -> AnyPublisher<Data, NetworkError>
}

public final class NetworkClient: ClientPublishing, ObservableObject {
    private var baseUrl: String
    private let session: URLSessionTaskable

    private var decoder: JSONDecoder = {
        let deconder = JSONDecoder()
        deconder.keyDecodingStrategy = .convertFromSnakeCase
        return deconder
    }()

    public init(baseUrl: String, session: URLSessionTaskable = URLSession.shared) {
        self.baseUrl = baseUrl
        self.session = session
    }

    public func request<T>(setup: Endpoint) -> AnyPublisher<T, NetworkError> where T: Decodable {
        let request: URLRequest

        do {
            request = try URLRequest(baseUrl: baseUrl, setup: setup)
            print("REQUEST")
            print(request.description)
        } catch let error as NetworkError {
            print(error.localizedDescription)
            return AnyPublisher(Fail<T, NetworkError>(error: error))
        } catch let error {
            print(error.localizedDescription)
            return AnyPublisher(Fail<T, NetworkError>(error: NetworkError.unknown(error.localizedDescription)))
        }

        return session
            .dataTaskAnyPublisher(for: request)
            .tryMap { [weak self] element -> Data in
                guard let self = self else {
                    throw NetworkError.unknown("")
                }

                print("RESPONSE")
                print(element.response.description)
                print("\(String(data: element.data, encoding: .utf8) ?? "")")

                guard let urlResponse = element.response as? HTTPURLResponse else {
                    throw NetworkError.invalidHttpUrlResponse
                }

                if let error = self.handleStatusError(code: urlResponse.statusCode,
                                                      data: element.data) {
                    print(error.localizedDescription)
                    throw error
                }

                return element.data
            }
            .decode(type: T.self, decoder: decoder)
            .mapError { error in
                switch error {
                case let decodeError as DecodingError:
                    return NetworkError.responseDecondingFailure(decodeError.localizedDescription)
                case let serviceError as NetworkError:
                    return serviceError
                default:
                    return NetworkError.unknown(error.localizedDescription)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func downloadData(url: URL) -> AnyPublisher<Data, NetworkError> {
        let request = URLRequest(url: url)
        print("REQUEST")
        print(request.description)

        return session.dataTaskAnyPublisher(for: request)
            .tryMap { [weak self] element -> Data in
                guard let self = self else {
                    throw NetworkError.unknown("")
                }

                print("RESPONSE")
                print(element.response.description)
                print("\(String(data: element.data, encoding: .utf8) ?? "")")

                guard let urlResponse = element.response as? HTTPURLResponse else {
                    throw NetworkError.invalidHttpUrlResponse
                }

                if let error = self.handleStatusError(code: urlResponse.statusCode,
                                                      data: element.data) {
                    print(error.localizedDescription)
                    throw error
                }

                return element.data
            }
            .mapError { error in
                switch error {
                case let decodeError as DecodingError:
                    return NetworkError.responseDecondingFailure(decodeError.localizedDescription)
                case let serviceError as NetworkError:
                    return serviceError
                default:
                    return NetworkError.unknown(error.localizedDescription)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    private func handleStatusError(code: Int, data: Data) -> NetworkError? {
        switch code {
        case 200...299:
            return nil
        case 401:
            return .authenticationRequired
        case 404:
            return .hostNotFound
        case 409:
            return .alreadyExist
        case 500:
            return .badRequest
        default:
            return .requestFailure(data)
        }
    }
}


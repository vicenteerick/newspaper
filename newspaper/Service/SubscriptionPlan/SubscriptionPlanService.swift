//
//  SubscriptionPlanService.swift
//  newspaper
//
//  Created by Erick Vicente on 31/07/24.
//

import Combine
import Foundation
import Network

protocol SubscriptionPlanServicing {
    func fetchPlan() -> AnyPublisher<NewspaperPlan, NetworkError>
    func downloadData(url: URL) -> AnyPublisher<Data, NetworkError>
}

class SubscriptionPlanService: SubscriptionPlanServicing {
    private let networkClient: ClientPublishing

    init(networkClient: ClientPublishing) {
        self.networkClient = networkClient
    }

    func fetchPlan() -> AnyPublisher<NewspaperPlan, NetworkError> {
        // networkClient.request(setup: SubscriptionPlanEndpoint.plan(id: "66a950f0e41b4d34e41961f8"))
        Future<NewspaperPlan, NetworkError> { promise in
            promise(.success(.mock))
        }.eraseToAnyPublisher()
    }

    func downloadData(url: URL) -> AnyPublisher<Data, NetworkError> {
        networkClient.downloadData(url: url)
    }
}


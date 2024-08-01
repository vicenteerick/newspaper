//
//  ImagePresenterViewModel.swift
//  newspaper
//
//  Created by Erick Vicente on 31/07/24.
//

import Combine
import Foundation
import enum Network.NetworkError

enum ImagePresenterViewModelError: Error, Equatable {
    case imageNotFound
}

enum ImagePresenterViewModelState: Equatable {
    case loading
    case finishedLoading
    case error(ImagePresenterViewModelError)
}

protocol SubscriptionPlanServiceBuilding {
    func build() -> SubscriptionPlanServicing
}

struct SubscriptionPlanServiceBuilder: SubscriptionPlanServiceBuilding {
    let service: SubscriptionPlanServicing

    func build() -> SubscriptionPlanServicing {
        service
    }
}

final class ImagePresenterViewModel {
    @Published private(set) var state: ImagePresenterViewModelState = .loading
    @Published private(set) var imageData: Data?

    private var service: SubscriptionPlanServicing
    private var cancellables = Set<AnyCancellable>()

    init(builder: SubscriptionPlanServiceBuilding) {
        self.service = builder.build()
    }
}

extension ImagePresenterViewModel {
    func downloadImage(url: URL) {
        let downloadImageDataCompletionHandler: (Subscribers.Completion<NetworkError>) -> Void = { [weak self] completion in
            switch completion {
            case .failure:
                self?.state = .error(.imageNotFound)
            case .finished:
                self?.state = .finishedLoading
            }
        }

        let downloadImageDataValueHandler: (Data) -> Void = { [weak self] imageData in
            self?.imageData = imageData
        }

        service
            .downloadData(url: url)
            .sink(receiveCompletion: downloadImageDataCompletionHandler,
                  receiveValue: downloadImageDataValueHandler)
            .store(in: &cancellables)

    }
}


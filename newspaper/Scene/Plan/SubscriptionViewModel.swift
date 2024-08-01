//
//  SubscriptionViewModel.swift
//  newspaper
//
//  Created by Erick Vicente on 31/07/24.
//

import Combine
import Foundation
import enum Network.NetworkError

enum SubscriptionViewModelError: Error, Equatable {
    case subscriptionNotFound
}

enum SubscriptionViewModelState: Equatable {
    case loading
    case finishedLoading
    case error(SubscriptionViewModelError)
}

final class SubscriptionViewModel {
    @Published private(set) var state: SubscriptionViewModelState = .loading
    @Published private(set) var headerLogoState: SubscriptionViewModelState = .loading
    @Published private(set) var coverImageState: SubscriptionViewModelState = .loading
    @Published private(set) var plan: NewspaperPlan?
    @Published private(set) var headerLogoData: Data?
    @Published private(set) var coverImageData: Data?

    private let service: SubscriptionPlanServicing
    private let dataManager: DataManager
    private let parser: NewspaperPlanParser

    private var cancellables = Set<AnyCancellable>()

    init(service: SubscriptionPlanServicing, dataManager: DataManager) {
        self.dataManager = dataManager
        self.parser = NewspaperPlanParser(dataManager: dataManager)
        self.service = service
    }
}

extension SubscriptionViewModel {
    func fetchPlan() {
        state = .loading

        do {
            let newspaperData = try dataManager.fetch(entity: .newspaperData)
            let plan = try parser.parse(entity: newspaperData)

            if plan.metadata.hasExpired() {
                fetchServicePlan()
            }

            self.plan = plan
            state = .finishedLoading
        } catch is DataManagerError {
            fetchServicePlan()
        } catch {
            state = .error(.subscriptionNotFound)
        }
    }
}

private extension SubscriptionViewModel {
    func fetchServicePlan() {
        let fetchPlanCompletionHandler: (Subscribers.Completion<NetworkError>) -> Void = { [weak self] completion in
            switch completion {
            case .failure:
                self?.state = .error(.subscriptionNotFound)
            case .finished:
                self?.state = .finishedLoading
            }
        }

        let fetchPlanValueHandler: (NewspaperPlan) -> Void = { [weak self] plan in
            self?.plan = plan
            self?.saveData(plan: plan)
        }

        service
            .fetchPlan()
            .sink(receiveCompletion: fetchPlanCompletionHandler,
                  receiveValue: fetchPlanValueHandler)
            .store(in: &cancellables)
    }

    func saveData(plan: NewspaperPlan) {
        if let newspaperData = try? dataManager.fetch(entity: .newspaperData) {
            try? dataManager.delete(object: newspaperData)
        }

        if let newspaperData = try? parser.parse(object: plan) {
            do {
                try dataManager.save()
            } catch {
                print(error)
            }
        }
    }
}


//
//  SubscriptionPlanViewController.swift
//  newspaper
//
//  Created by Erick Vicente on 31/07/24.
//

import Combine
import UIKit

class SubscriptionPlanViewController: UIViewController {
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let containerStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let containerHeaderImageView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var headerImageView: ImagePresenterView = {
        let view = ImagePresenterView(serviceBuilder: serviceBuilder)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var coverImageView: ImagePresenterView = {
        let view = ImagePresenterView(serviceBuilder: serviceBuilder)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let planDescriptionView: PlanDescriptionView = {
        let view = PlanDescriptionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let offersView: OffersView = {
        let view = OffersView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let benefitsView: BenefitsView = {
        let view = BenefitsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let bottomView: BottomView = {
        let view = BottomView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let loadingView: LoadingView = {
        let view = LoadingView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let viewModel: SubscriptionViewModel
    private let serviceBuilder: SubscriptionPlanServiceBuilding

    private var cancellables = Set<AnyCancellable>()

    init(viewModel: SubscriptionViewModel, serviceBuilder: SubscriptionPlanServiceBuilding) {
        self.viewModel = viewModel
        self.serviceBuilder = serviceBuilder
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
    }

    private func setupController() {
        buildViewHierarchy()
        setupConstraints()
        bindViewModelToView()
        viewModel.fetchPlan()
    }

    private func bindViewModelToView() {
        let stateValueHandler: (SubscriptionViewModelState) -> Void = { [weak self] state in
            guard let self = self else { return }
            switch state {
            case .loading:
                self.loadingView.isHidden = false
            case .finishedLoading:
                self.loadingView.isHidden = true
            case .error(let error):
                self.loadingView.isHidden = true
                self.showError(error)
            }
        }

        viewModel.$state
            .receive(on: RunLoop.main)
            .sink(receiveValue: stateValueHandler)
            .store(in: &cancellables)

        viewModel.$plan
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] plan in
                guard let self = self,
                      let plan = plan else { return }

                self.coverImageView.setupView(imageUrl: plan.record.subscription.coverImage)
                self.headerImageView.setupView(imageUrl: plan.record.headerLogo)
                self.planDescriptionView.setupView(title: plan.record.subscription.subscribeTitle,
                                                   subtitle: plan.record.subscription.subscribeSubtitle)

                self.offersView.setupView(offers: plan.record.subscription.offers) { offer in
                    print("Selected Offer price: \(offer.price)")
                }

                self.benefitsView.setupView(benefits: plan.record.subscription.benefits)
                self.bottomView.setupView(disclaimer: plan.record.subscription.disclaimer) {
                    print("Subscribed")
                }
            })
            .store(in: &cancellables)
    }

    private func showError(_ error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Retry", style: .default) { [unowned self] _ in
            self.viewModel.fetchPlan()
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
}

private extension SubscriptionPlanViewController {
    func buildViewHierarchy() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(headerImageView)
        scrollView.addSubview(containerStackView)

        containerStackView.addArrangedSubview(coverImageView)
        containerStackView.addArrangedSubview(planDescriptionView)
        containerStackView.addArrangedSubview(offersView)
        containerStackView.addArrangedSubview(benefitsView)
        containerStackView.addArrangedSubview(bottomView)

        view.addSubview(loadingView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),

            headerImageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            headerImageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            headerImageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            headerImageView.bottomAnchor.constraint(equalTo: containerStackView.topAnchor),
            headerImageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            containerStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            containerStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            containerStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

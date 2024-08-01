//
//  ImagePresenterView.swift
//  newspaper
//
//  Created by Erick Vicente on 31/07/24.
//

import Combine
import UIKit

class ImagePresenterView: UIView {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let loadingView: LoadingView = {
        let view = LoadingView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let viewModel: ImagePresenterViewModel

    private var cancellables = Set<AnyCancellable>()

    init(serviceBuilder: SubscriptionPlanServiceBuilding) {
        viewModel = ImagePresenterViewModel(builder: serviceBuilder)
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        buildViewHierarchy()
        setupConstraints()
        bindViewModelToView()
    }

    private func bindViewModelToView() {
        let stateValueHandler: (ImagePresenterViewModelState) -> Void = { [weak self] state in
            guard let self = self else { return }
            switch state {
            case .loading:
                self.loadingView.isHidden = false
            case .finishedLoading:
                self.loadingView.isHidden = true
            case .error(_):
                self.loadingView.isHidden = true
            }
        }

        viewModel.$state
            .receive(on: RunLoop.main)
            .sink(receiveValue: stateValueHandler)
            .store(in: &cancellables)

        viewModel.$imageData
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] imageData in
                guard let self = self,
                      let imageData = imageData,
                      let image = UIImage(data: imageData) else { return }
                self.imageView.image = image
                self.imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor, 
                                                       multiplier: image.size.height / image.size.width).isActive = true
            })
            .store(in: &cancellables)
    }

    func setupView(imageUrl: URL) {
        viewModel.downloadImage(url: imageUrl)
    }
}

private extension ImagePresenterView {
    func buildViewHierarchy() {
        addSubview(imageView)
        addSubview(loadingView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),

            loadingView.topAnchor.constraint(equalTo: topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

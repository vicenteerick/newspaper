//
//  LoadingView.swift
//  newspaper
//
//  Created by Erick Vicente on 31/07/24.
//

import UIKit

final class LoadingView: UIView {
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()

    private lazy var blurredEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        buildViewHierarchy()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension LoadingView {
    func buildViewHierarchy() {
        blurredEffectView.contentView.addSubview(activityIndicator)
        addSubview(blurredEffectView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: blurredEffectView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: blurredEffectView.centerYAnchor),

            blurredEffectView.topAnchor.constraint(equalTo: self.topAnchor),
            blurredEffectView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            blurredEffectView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            blurredEffectView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
}

extension LoadingView {
    func startLoading() {
        activityIndicator.startAnimating()
    }
}

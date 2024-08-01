//
//  BenefitsView.swift
//  newspaper
//
//  Created by Erick Vicente on 31/07/24.
//

import UIKit

class BenefitsView: UIView {
    private let containerStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var messageContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                          action: #selector(messagTapped)))
        return view
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .black
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "What is \"News+\"?"
        return label
    }()

    private let downArrowImage: UIImageView = {
        let imageView = UIImageView(image: .init(systemName: "chevron.down"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let benefitsStackView: UIStackView = {
        let view = UIStackView()
        view.spacing = 8
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    init() {
        super.init(frame: .zero)
        buildViewHierarchy()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView(benefits: [String]) {
        benefits.forEach { bennefit in
            benefitsStackView.addArrangedSubview(buildLabel(text: bennefit))
        }
    }

    private func buildLabel(text: String) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        return label
    }

    @objc private func messagTapped() {
        let isHidden = !benefitsStackView.isHidden

        UIView.animate(withDuration: 0.3) {
            self.benefitsStackView.isHidden = isHidden
            self.containerStackView.layoutIfNeeded()
        }
    }
}

private extension BenefitsView {
    func buildViewHierarchy() {
        containerStackView.addArrangedSubview(messageContainer)
        containerStackView.addArrangedSubview(benefitsStackView)

        messageContainer.addSubview(messageLabel)
        messageContainer.addSubview(downArrowImage)

        addSubview(containerStackView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: topAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),

            messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: messageContainer.leadingAnchor),
            downArrowImage.trailingAnchor.constraint(lessThanOrEqualTo: messageContainer.trailingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: downArrowImage.leadingAnchor, constant: -8),
            messageLabel.topAnchor.constraint(equalTo: messageContainer.topAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: messageContainer.bottomAnchor),
            messageLabel.centerXAnchor.constraint(equalTo: messageContainer.centerXAnchor),
        ])
    }
}

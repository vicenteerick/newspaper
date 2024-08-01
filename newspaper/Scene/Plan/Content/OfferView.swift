//
//  OfferView.swift
//  newspaper
//
//  Created by Erick Vicente on 31/07/24.
//

import UIKit

class OfferView: UIView {
    private let containerStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var checkboxButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        button.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        return button
    }()

    private var didSelectItem: (() -> Void)?

    init() {
        super.init(frame: .zero)
        buildViewHierarchy()
        setupConstraints()
        addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                    action: #selector(didTapButton)))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView(offer: Offer, isSelected: Bool, didSelectItem: @escaping (Offer) -> Void) {
        priceLabel.text = offer.price.toCurrencyString()
        descriptionLabel.text = offer.description
        checkboxButton.isSelected = isSelected

        self.didSelectItem = {
            didSelectItem(offer)
        }
    }

    func diselectButton() {
        guard checkboxButton.isSelected else { return }
        checkboxButton.isSelected = false
    }

    @objc private func didTapButton() {
        guard !checkboxButton.isSelected else { return }
        checkboxButton.isSelected = true
        didSelectItem?()
    }
}

private extension OfferView {
    func buildViewHierarchy() {
        containerStackView.addArrangedSubview(priceLabel)
        containerStackView.addArrangedSubview(descriptionLabel)
        containerStackView.addArrangedSubview(checkboxButton)
        addSubview(containerStackView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: topAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

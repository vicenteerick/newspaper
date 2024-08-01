//
//  OffersView.swift
//  newspaper
//
//  Created by Erick Vicente on 31/07/24.
//

import UIKit

class OffersView: UIView {
    private let containerStackView: UIStackView = {
        let view = UIStackView()
        view.distribution = .fillEqually
        view.spacing = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let mainOffer: OfferView = OfferView()
    private let secondaryOffer: OfferView = OfferView()

    private var didSelectItem: (() -> Void)?

    init() {
        super.init(frame: .zero)
        buildViewHierarchy()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView(offers: Offers, didSelectItem: @escaping (Offer) -> Void) {
        mainOffer.setupView(offer: offers.id0, isSelected: true) { [weak self] offer in
            didSelectItem(offer)
            self?.secondaryOffer.diselectButton()
        }

        secondaryOffer.setupView(offer: offers.id1, isSelected: false) { [weak self] offer in
            didSelectItem(offer)
            self?.mainOffer.diselectButton()
        }
    }
}

private extension OffersView {
    func buildViewHierarchy() {
        containerStackView.addArrangedSubview(mainOffer)
        containerStackView.addArrangedSubview(secondaryOffer)
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

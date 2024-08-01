//
//  BottomView.swift
//  newspaper
//
//  Created by Erick Vicente on 31/07/24.
//

import UIKit

class BottomView: UIView {
    private let containerStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.setTitle("Subscribe Now", for: .normal)
        return button
    }()

    private let disclaimerTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = .black
        textView.textAlignment = .center
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    var didSubscribe: (() -> Void)?

    init() {
        super.init(frame: .zero)
        buildViewHierarchy()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView(disclaimer: String, didSubscribe: @escaping () -> Void) {
        disclaimerTextView.attributedText = disclaimer.parseMarkdownText()
        self.didSubscribe = didSubscribe
    }
}

private extension BottomView {
    func buildViewHierarchy() {
        containerStackView.addArrangedSubview(button)
        containerStackView.addArrangedSubview(disclaimerTextView)
        addSubview(containerStackView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: self.topAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),

            button.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}

extension BottomView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        return false
    }
}

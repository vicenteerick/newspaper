//
//  StringMarkdown.swift
//  newspaper
//
//  Created by Erick Vicente on 31/07/24.
//

import UIKit

extension String {
    func parseMarkdownText() -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        guard let regex = try? NSRegularExpression(pattern: "\\[(.*?)\\]\\((.*?)\\)") else {
            return attributedString
        }

        let matches = regex.matches(in: self, 
                                    options: [],
                                    range: NSRange(location: 0, length: utf16.count))

        for match in matches.reversed() {
            guard match.numberOfRanges == 3,
                  let linkRange = Range(match.range(at: 2), in: self),
                  let textRange = Range(match.range(at: 1), in: self) else { continue }

            let urlString = String(self[linkRange])
            let linkText = String(self[textRange])
            let fullMatchRange = match.range(at: 0)
            
            if let url = URL(string: urlString) {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 5.0

                let replacementText = NSAttributedString(string: linkText,
                                                         attributes: [.link: url,
                                                                      .foregroundColor: UIColor.blue,
                                                                      .font: UIFont.systemFont(ofSize: 13, weight: .regular),
                                                                      .paragraphStyle: paragraphStyle])

                attributedString.replaceCharacters(in: fullMatchRange, with: replacementText)
            }
        }

        return attributedString
    }
}

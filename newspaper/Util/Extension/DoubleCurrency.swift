//
//  DoubleCurrency.swift
//  newspaper
//
//  Created by Erick Vicente on 31/07/24.
//

import Foundation

extension Double {
    func toCurrencyString(locale: Locale = Locale.current, currencyCode: String = "USD") -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        formatter.currencyCode = currencyCode
        return formatter.string(from: NSNumber(value: self))
    }
}

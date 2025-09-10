//
//  Formatting.swift
//  StoryCash
//
//  Created by Mykhailo Kravchuk on 09/09/2025.
//

import Foundation

extension NumberFormatter {
    static let moneyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = Locale.current.groupingSeparator
        formatter.decimalSeparator = Locale.current.decimalSeparator
        return formatter
    }()
}

extension Double {
    func asMoneyString() -> String {
        return NumberFormatter.moneyFormatter.string(from: NSNumber(value: self)) ?? String(format: "%.2f", self)
    }
}



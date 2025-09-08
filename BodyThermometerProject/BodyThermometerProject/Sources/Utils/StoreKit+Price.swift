//
//  StoreKit+Price.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 8.09.25.
//

import StoreKit

extension SKProduct {
    var formattedPrice: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)
    }
}

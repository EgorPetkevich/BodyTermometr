//
//  PaywallProduct.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 8.09.25.
//

import StoreKit
import ApphudSDK

struct PaywallProduct: Identifiable {
    let id: String
    let period: Product.SubscriptionPeriod.Unit.FormatStyle?
    let price: String?
    let apphudProduct: ApphudProduct

    init(from product: ApphudProduct) async {
        self.id = product.productId
        self.period = try? await product.product()?.subscriptionPeriodUnitFormatStyle
        self.price = product.skProduct?.formattedPrice
        self.apphudProduct = product
    }
}



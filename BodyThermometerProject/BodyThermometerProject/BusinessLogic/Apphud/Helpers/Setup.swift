//
//  Setup.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 8.09.25.
//

import Foundation

//MARK: - Helpers
enum PaywallId: String {
    case onboarding = "onboarding_paywall"
    case inApp = "inapp_paywall"
}

enum ProductType {
    case trial
    case prod
}


//MARK: - Errors
enum PurchaseError: Error {
    case productNotFound
}

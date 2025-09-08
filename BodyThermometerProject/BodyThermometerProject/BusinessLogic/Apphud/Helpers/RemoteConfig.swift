//
//  RemoteConfig.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 8.09.25.
//

import Foundation

struct RemoteConfig: Decodable {
    var onboardingCloseDelay: Double = 0
    var paywallCloseDelay: Double = 0
    var onboardingButtonTitle: String?
    var paywallButtonTitle: String?
    var onboardingSubtitleAlpha: Double = 1.0
    var isPagingEnabled: Bool = false
    var isReviewEnabled: Bool = false
}

//
//  ApphudManager+Prod.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 8.09.25.
//

import Foundation
import RxSwift
import RxCocoa
import ApphudSDK
import StoreKit

struct PaywallProdApphudManagerUseCase: PaywallProdApphudManagerUseCaseProtocol {
    
    var config: RemoteConfig
    
    private let apphudService: ApphudRxManager
    
    init(apphudService: ApphudRxManager) {
        self.apphudService = apphudService
        self.config = apphudService.configRelay.value
    }
    
    func getProdPrice() -> String? {
        let prod = apphudService.product(for: .prod)
        return prod?.price
    }
    
    func makePurchase() -> Single<ApphudSubscription> {
        guard
            let prod = apphudService.product(for: .prod)
        else { return Single.error(PurchaseError.productNotFound) }
        return apphudService.purchase(prod.apphudProduct)
    }
    
    func restorePurchases() -> Single<Bool> {
        apphudService.restorePurchases()
    }
    
}


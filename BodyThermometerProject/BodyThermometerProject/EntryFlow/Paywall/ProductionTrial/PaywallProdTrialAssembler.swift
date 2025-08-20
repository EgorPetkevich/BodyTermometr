//
//  PaywallProdTrialAssembler.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 14.08.25.
//

import UIKit

final class PaywallProdTrialAssembler {
    
    private init() {}
    
    static func assemble(container: Container) -> UIViewController {
        let router = PaywallProdTrialRouter(container: container)
        let viewModel = PaywallProdTrialVM(router: router)
        let viewController = PaywallProdTrialVC(viewMode: viewModel)
        
        router.root = viewController
        return viewController
    }
    
}

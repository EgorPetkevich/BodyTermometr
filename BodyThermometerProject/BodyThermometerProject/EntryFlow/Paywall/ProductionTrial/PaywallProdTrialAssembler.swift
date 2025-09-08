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
        let alertService =
        PaywallProdTrialAlertServiceUseCase(
            alertService: AlertManagerService(container: container)
        )
        let apphudManager =
        PaywallProdTrialApphudManagerUseCase(apphudService: container.resolve())
        let viewModel = PaywallProdTrialVM(router: router,
                                           apphudManager: apphudManager,
                                           alertService: alertService)
        let viewController = PaywallProdTrialVC(viewMode: viewModel)
        
        router.root = viewController
        return viewController
    }
    
}

//
//  PaywallProdAssembler.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 15.08.25.
//

import UIKit

final class PaywallProdAssembler {
    
    private init() {}
    
    static func assemble(container: Container) -> UIViewController {
        let router = PaywallProdRouter(container: container)
        let alertService =
        PaywallProdAlertServiceUseCase(
            alertService: AlertManagerService(container: container)
        )
        let apphudManager =
        PaywallProdApphudManagerUseCase(apphudService: container.resolve())
        
        let viewModel = PaywallProdVM(router: router,
                                      apphudManager: apphudManager,
                                      alertService: alertService)
        let viewController = PaywallProdVC(viewMode: viewModel)
        
        router.root = viewController
        return viewController
    }
    
}

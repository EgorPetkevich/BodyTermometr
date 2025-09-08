//
//  PaywallRevAssembler.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 15.08.25.
//

import UIKit

final class PaywallRevAssembler {
    
    private init() {}
    
    static func assemble(container: Container,
                         _ startFlow: Bool = false)
    -> UIViewController {
        let router = PaywallRevRouter(container: container,
                                      startFlow: startFlow)
        let apphudManager =
        PaywallRevApphudManagerUseCase(
            apphudService: container.resolve()
        )
        let alertService =
        PaywallRevAlertServiceUseCase(
            alertService: AlertManagerService(container: container)
        )
        let viewModel = PaywallRevVM(
            router: router,
            apphudManager: apphudManager,
            alertService: alertService
        )
        let viewController = PaywallRevVC(viewMode: viewModel)
        
        router.root = viewController
        return viewController
    }
    
}


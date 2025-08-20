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
        let viewModel = PaywallProdVM(router: router)
        let viewController = PaywallProdVC(viewMode: viewModel)
        
        router.root = viewController
        return viewController
    }
    
}

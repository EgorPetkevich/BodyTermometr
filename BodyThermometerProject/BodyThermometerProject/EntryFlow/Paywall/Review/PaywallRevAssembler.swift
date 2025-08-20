//
//  PaywallRevAssembler.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 15.08.25.
//

import UIKit

final class PaywallRevAssembler {
    
    private init() {}
    
    static func assemble(container: Container) -> UIViewController {
        let router = PaywallRevRouter(container: container)
        let viewModel = PaywallRevVM(router: router)
        let viewController = PaywallRevVC(viewMode: viewModel)
        
        router.root = viewController
        return viewController
    }
    
}


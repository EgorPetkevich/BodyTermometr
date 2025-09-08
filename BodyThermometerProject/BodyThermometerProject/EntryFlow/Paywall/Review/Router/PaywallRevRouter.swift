//
//  PaywallRevRouter.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 15.08.25.
//

import UIKit

final class PaywallRevRouter: PaywallRevRouterProtocol {
    
    weak var root: UIViewController?
    
    private var container: Container
    private var flow: AppFlow
    private var startFlow: Bool
    
    init(container: Container, startFlow: Bool) {
        self.container = container
        self.startFlow = startFlow
        self.flow = container.resolve()
    }
    
    func finish() {
        if startFlow {
            flow.didFinishPaywall.accept(())
            return
        }
        root?.dismiss(animated: true)
    }
    
}


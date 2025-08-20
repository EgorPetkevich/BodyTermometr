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
    
    init(container: Container) {
        self.container = container
        self.flow = container.resolve()
    }
    
    func finish() {
        flow.didFinishPaywall.accept(())
    }
    
}


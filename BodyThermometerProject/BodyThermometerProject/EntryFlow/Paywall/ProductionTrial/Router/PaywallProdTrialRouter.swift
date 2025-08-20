//
//  PaywallProdTrialRouter.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 14.08.25.
//

import UIKit

final class PaywallProdTrialRouter: PaywallProdTrialRouterProtocol {
    
    weak var root: UIViewController?
    
    private let container: Container
    private let flow: AppFlow
    
    init(container: Container) {
        self.container = container
        self.flow = container.resolve()
    }
    
    func finish() {
        flow.didFinishPaywall.accept(())
    }
    
}

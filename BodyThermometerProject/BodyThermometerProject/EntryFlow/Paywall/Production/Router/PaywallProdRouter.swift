//
//  PaywallProdRouter.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 15.08.25.
//

import UIKit

final class PaywallProdRouter: PaywallProdRouterProtocol {
    
    weak var root: UIViewController?
    
    private let container: Container
    private let flow: AppFlow
    
    init(container: Container) {
        self.container = container
        self.flow = container.resolve()
    }
    
    func finish() {
        UDManagerService.setIsOnboardingShown(true)
        flow.didFinishOnboarding.accept(())
    }
    
}

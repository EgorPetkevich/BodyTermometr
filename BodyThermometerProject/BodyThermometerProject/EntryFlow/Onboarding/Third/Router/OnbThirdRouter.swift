//
//  OnbThirdRouter.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 14.08.25.
//

import UIKit

final class OnbThirdRouter: OnbThirdRouterProtocol {
    
    weak var viewController: UIViewController?
    
    var container: Container
    var flow: AppFlow
    
    init(container: Container) {
        self.container = container
        self.flow = container.resolve()
    }
    
    func goNext() {
        flow.didFinishOnboarding.accept(())
    }
}

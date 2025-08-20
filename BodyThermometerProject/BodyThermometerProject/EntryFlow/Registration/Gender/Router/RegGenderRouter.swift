//
//  RegGenderRouter.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 17.08.25.
//

import UIKit

final class RegGenderRouter: RegGenderRouterProtocol {
    
    weak var root: UIViewController?
    
    private var flow: AppFlow
    
    private var container: Container
    
    init(container: Container) {
        self.container = container
        self.flow = container.resolve()
    }
    
    func continueTapped() {
        flow.didFinishRegistration.accept(())
    }
    
    func crossTapped() {
        flow.didFinishRegistration.accept(())
    }
    
}

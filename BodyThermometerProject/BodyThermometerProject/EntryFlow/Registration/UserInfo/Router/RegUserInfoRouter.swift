//
//  RegistrationUserInfoRouter.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 17.08.25.
//

import UIKit

final class RegUserInfoRouter: RegUserInfoRouterProtocol {
    
    weak var root: UIViewController?
    private let flow: AppFlow
    
    private let container: Container
    
    init(container: Container) {
        self.container = container
        self.flow = container.resolve()
    }
    
    func continueTapped() {
        let vc = RegGenderAssembler.assembly(container: container)
        root?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func crossTapped() {
        flow.didFinishRegistration.accept(())
    }
    
}

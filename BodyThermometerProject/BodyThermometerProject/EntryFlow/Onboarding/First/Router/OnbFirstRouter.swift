//
//  FirstScreenOnboardingRouter.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 13.08.25.
//

import UIKit

final class OnbFirstRouter: OnbFirstRouterProtocol {
    
    weak var root: UIViewController?
    
    private let contaier: Container
    
    init(container: Container) {
        self.contaier = container
    }
    
    func goNext() {
        let vc = OnbSecondAssebler.assembly(container: contaier)
        root?.navigationController?.pushViewController(vc, animated: true)
    }
    
}

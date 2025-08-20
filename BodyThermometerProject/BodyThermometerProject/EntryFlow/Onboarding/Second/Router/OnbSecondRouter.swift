//
//  SecondScreenOnboradingRouter.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 14.08.25.
//

import UIKit

final class OnbSecondRouter: OnbSecondRouterProtocol {
    
    weak var root: UIViewController?
    
    private let contaier: Container
    
    init(container: Container) {
        self.contaier = container
    }
    
    func goNext() {
        let vc = OnbThirdAssebler.assembly(container: contaier)
        root?.navigationController?.pushViewController(vc, animated: true)
    }
}

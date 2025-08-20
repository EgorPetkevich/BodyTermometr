//
//  FirstScreenOnboardingRouter.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 13.08.25.
//

import UIKit

final class OnbFirstRouter: OnbFirstRouterProtocol {
    
    weak var root: UIViewController?
    
    func goNext() {
        let vc = OnbSecondAssebler.assembly()
        root?.navigationController?.pushViewController(vc, animated: true)
    }
    
}

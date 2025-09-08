//
//  SecondScreenOnboradingAssembler.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 14.08.25.
//

import UIKit

final class OnbSecondAssebler {
    
    private init() {}
    
    static func assembly(container: Container) -> UIViewController {
        let router = OnbSecondRouter(container: container)
        let apphudManager =
        OnbSecondApphudManagerUseCase(apphudService: container.resolve())
        let viewModel = OnbSecondVM(router: router,
                                    apphudManager: apphudManager)
        let viewController = OnbSecondVC(viewModel: viewModel)
        
        router.root = viewController
        
        return viewController
    }
    
}

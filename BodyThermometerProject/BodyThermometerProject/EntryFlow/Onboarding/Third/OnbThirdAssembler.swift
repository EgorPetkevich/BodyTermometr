//
//  OnbThirdAssembler.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 14.08.25.
//

import UIKit

final class OnbThirdAssebler {
    
    private init() {}
    
    static func assembly(container: Container) -> UIViewController {
        let router = OnbThirdRouter(container: container)
        let apphudManager =
        OnbThirdApphudManagerUseCase(apphudService: container.resolve())
        let viewModel = OnbThirdVM(router: router,
                                   apphudManager: apphudManager)
        let viewController = OnbThirdVC(viewModel: viewModel)
        
        router.viewController = viewController
        
        return viewController
    }
    
}

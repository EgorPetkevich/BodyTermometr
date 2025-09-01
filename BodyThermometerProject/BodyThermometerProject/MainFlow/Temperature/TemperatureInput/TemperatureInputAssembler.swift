//
//  TemperatureInputAssembler.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 30.08.25.
//

import UIKit

final class TemperatureInputAssembler {
    
    private init() {}
    
    static func assembly(container: Container) -> UIViewController {
        let router = TemperatureInputRouter(container: container)
        let keyboardHelper =
        TemperatureInputKeyBoardHelperServiceUseCase(
            keyBoardHelperService: container.resolve()
        )
        let viewModel = TemperatureInputVM(router: router,
                                           keyboardHelper: keyboardHelper)
        let viewController = TemperatureInputVC(viewModel: viewModel)
        
        router.root = viewController
        return viewController
    }
    
}

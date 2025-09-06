//
//  TemperatureInputAssembler.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 30.08.25.
//

import UIKit
import RxRelay

final class TemperatureInputAssembler {
    
    private init() {}
    
    static func assembly(
        container: Container,
        _ dto: TempModelDTO? = nil,
    ) -> UIViewController {
        let router = TemperatureInputRouter(container: container, dto)
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

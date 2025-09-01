//
//  MeasuringAssembler.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 26.08.25.
//

import UIKit

final class MeasuringAssembler {
    
    private init() {}
    
    static func assembly(container: Container) -> UIViewController {
        let router = MeasuringRouter(container: container)
        let viewModel = MeasuringVM(router: router)
        let viewController = MeasuringVC(viewModel: viewModel)
        
        router.root = viewController
        return viewController
    }
    
}

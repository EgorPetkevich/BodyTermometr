//
//  MeasuringGuideAssembler.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 26.08.25.
//

import UIKit

final class MeasuringGuideAssembler {
    
    private init() {}
    
    static func assembly() -> UIViewController {
        let router = MeasuringGuideRouter()
        let viewModel = MeasuringGuideVM(router: router)
        let viewController = MeasuringGuideVC(viewModel: viewModel)
        
        router.root = viewController
        return viewController
    }
    
}

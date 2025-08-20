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
        let viewModel = OnbThirdVM(router: router)
        let viewController = OnbThirdVC(viewModel: viewModel)
        
        router.viewController = viewController
        
        return viewController
    }
    
}

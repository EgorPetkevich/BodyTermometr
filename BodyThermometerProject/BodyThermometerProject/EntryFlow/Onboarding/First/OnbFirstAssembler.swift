//
//  FirstScreenOnboardingBuilder.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 13.08.25.
//

import UIKit

final class OnbFirstAssembler {
    
    private init() {}
    
    static func assembly(container: Container) -> UIViewController {
        let router = OnbFirstRouter(container: container)
        let viewModel = OnbFirstVM(router: router)
        let viewController = OnbFirstVC(viewModel: viewModel)
        router.root = viewController
        
        return viewController
    }
    
}

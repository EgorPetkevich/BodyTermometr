//
//  SettingsAssembler.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 24.08.25.
//

import UIKit

final class SettingsAssembler {
    
    private init() {}
    
    static func assembly(container: Container) -> UIViewController {
        let router = SettingsRouter(container: container)
        let viewModel = SettingsVM(router: router)
        let viewController = SettingsVC(viewModel: viewModel)
        
        router.root = viewController
        return viewController
    }
    
}


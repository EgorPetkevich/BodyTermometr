//
//  RegGenderAssembler.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 17.08.25.
//

import UIKit

final class RegGenderAssembler {
    
    private init() {}
    
    static func assembly(container: Container) -> UIViewController {
        let router = RegGenderRouter(container: container)
        
        let realmDataManager =
        RegGenderRealDataManagerUseCase(realmDataManager: container.resolve())
        
        let viewModel = RegGenderVM(router: router,
                                    realDataManager: realmDataManager)
        let viewController = RegGenderVC(viewModel: viewModel)
        
        router.root = viewController
        
        return viewController
    }
    
}

//
//  MainAssembler.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 18.08.25.
//

import UIKit

final class MainAssembler {
    
    private init() {}
    
    static func assembly(container: Container) -> UIViewController {
        let router = MainRouter(container: container)
        let realmDataManager =
        MainRealmDataManagerUseCase(realmDataManager: container.resolve())
        let fileManagerService =
        MainFileManagerServiceUseCase(fileManager: container.resolve())
        let viewModel = MainVM(router: router,
                               realmDataManager: realmDataManager,
                               fileManageService: fileManagerService)
        let viewController = MainVC(viewModel: viewModel)
        
        router.root = viewController
        return viewController
    }
    
}


//
//  RegistrationUserInfoAssembler.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 17.08.25.
//

import UIKit

final class RegUserInfoAssembler {
    
    private init() {}
    
    static func assembly(container: Container) -> UIViewController {
        let router = RegUserInfoRouter(container: container)
        
        let realmDataManager =
        RegUserInfoRealDataManagerUseCase(realmDataManager: container.resolve())
        let keyBoardHelperService =
        RegUserInfoKeyBoardHelperServiceUseCase(
            keyBoardHelperService: container.resolve())
        
        let viewModel = RegUserInfoVM(router: router,
                                      keyBoardHelper: keyBoardHelperService,
                                      realmDataManager: realmDataManager)
        let viewController = RegUserInfoVC(viewModel: viewModel)
        
        router.root = viewController
        
        return viewController
    }
}

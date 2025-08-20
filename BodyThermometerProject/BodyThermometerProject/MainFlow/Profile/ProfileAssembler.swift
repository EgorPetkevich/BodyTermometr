//
//  ProfileAssembler.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 20.08.25.
//

import UIKit

final class ProfileAssembler {
    
    private init() {}
    
    static func assebly(container: Container) -> UIViewController {
        let router = ProfileRouter(container: container)
        let realmDataManager =
        ProfileRealmDataManagerUseCase(realmDataManager: container.resolve())
        let keybordHelper = ProfileKeyBoardHelperServiceUseCase(keyBoardHelperService: container.resolve())
        let viewModel = ProfileVM(router: router,
                                  realmDataManager: realmDataManager,
                                  keyboardHelper: keybordHelper)
        let viewController = ProfileVC(viewModel: viewModel)
                                       
        
        router.root = viewController
        return viewController
    }
    
}

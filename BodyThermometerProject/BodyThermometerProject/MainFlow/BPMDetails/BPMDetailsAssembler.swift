//
//  BPMDetailsAssembler.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 4.09.25.
//

import UIKit

final class BPMDetailsAssembler {
    
    private init() {}
    
    static func assembly(container: Container,
                         dto: BPMModelDTO
    ) -> UIViewController {
        let router = BPMDetailsRouter(container: container)
        
        let realmManager =
        BPMDetailsRealmBPMManagerUseCase(
            bpmRealmManager: container.resolve()
        )
        
        let alertServiceManager =
        BPMDetailsAlertManagerServiceUseCase(
            alertServiceManager: AlertManagerService(container: container) 
        )
        
        let viewModel = BPMDetailsVM(
            router: router,
            collection: ActivityCollection(),
            realmBPMManager: realmManager,
            alertManagerService: alertServiceManager,
            dto: dto
        )
        let viewController = BPMDetailsVC(viewModel: viewModel)
        
        router.root = viewController
        
        return viewController
    }
    
}

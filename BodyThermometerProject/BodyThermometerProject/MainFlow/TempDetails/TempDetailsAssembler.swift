//
//  TempDetailsAssembler.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 4.09.25.
//

import UIKit

final class TempDetailsAssembler {
    
    private init() {}
    
    static func assembly(
        container: Container,
        dto: TempModelDTO,
        unit: TempUnit
    ) -> UIViewController {
        let router = TempDetailsRouter(container: container)
        let realmTempService =
        TempDetailsRealmBPMManagerUseCase(tempRealmManager: container.resolve())
        let alertManagerService =
        TempDetailsAlertManagerServiceUseCase(alertServiceManager: AlertManagerService(container: container))
        
        let viewModel = TempDetailsVM(
            dto: dto,
            router: router,
            tempUnit: unit,
            symptomsCollection: SymptomsCollection(),
            feelingCollection: FeelingCollection(),
            alertManagerService: alertManagerService,
            realmTempManager: realmTempService)
     
        let viewController = TempDetailsVC(viewModel: viewModel)
        
        router.root = viewController
        return viewController
    }
    
}

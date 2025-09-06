//
//  TempConditionAssembler.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 30.08.25.
//

import UIKit

final class TempConditionAssembler {
    
    private init() {}
    
    static func assembly(
        container: Container,
        temp: Double,
        unit: TempUnit,
        _ dto: TempModelDTO? = nil
    ) -> UIViewController {
            let router = TempConditionRouter(container: container)
        
        let symptomsCollection = SymptomsCollection()
        let feelingCollection = FeelingCollection()
        let realmDataManager =
        TempConditionRealmDataManagerUseCase(tempDataManage: container.resolve())
        let viewModel = TempConditionVM(router: router,
                                        temperature: temp,
                                        tempUnit: unit,
                                        symptomsCollection: symptomsCollection,
                                        feelingCollection: feelingCollection,
                                        realmDataManager: realmDataManager,
                                        dto)
        let viewController = TempConditionVC(viewModel: viewModel)
        
        router.root = viewController
        return viewController
    }
    
}

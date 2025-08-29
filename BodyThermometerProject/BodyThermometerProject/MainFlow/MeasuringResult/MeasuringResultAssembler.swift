//
//  MeasuringResultAssembler.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 27.08.25.
//

import UIKit

final class MeasuringResultAssembler {
    
    private init() {}
    
    static func assembly(container: Container, bpmResult: Int) -> UIViewController {
        let router = MeasuringResultRouter()
        let collection = ActivityCollection()
        
        let realmManager =
        MeasuringResultRealmBPMManagerUseCase(realm: container.resolve())
        
        let viewModel = MeasuringResultVM(router: router,
                                          collection: collection,
                                          realmManager: realmManager,
                                          bpmResult: bpmResult)
        let viewController = MeasuringResultVC(viewModel: viewModel)
        
        router.root = viewController
        return viewController
    }
    
}

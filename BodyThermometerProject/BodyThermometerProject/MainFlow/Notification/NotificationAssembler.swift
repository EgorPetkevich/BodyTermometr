//
//  NotificationAssembler.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 25.08.25.
//

import UIKit

final class NotificationAssembler {
    
    private init() {}
    
    static func assembly(container: Container) -> UIViewController {
        let router = NotificationRouter()
        let alertService = NotificationAlertServiceUseCase(alertService: AlertManagerService(container: container))
        let viewModel = NotificationVM(router: router,
                                       alertService: alertService)
        let viewController = NotificationVC(viewModel: viewModel)
        
        router.root = viewController
        return viewController
    }
    
}

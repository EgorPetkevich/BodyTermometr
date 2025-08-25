//
//  NotificationAssembler.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 25.08.25.
//

import UIKit

final class NotificationAssembler {
    
    private init() {}
    
    static func assembly() -> UIViewController {
        let router = NotificationRouter()
        let viewModel = NotificationVM(router: router)
        let viewController = NotificationVC(viewModel: viewModel)
        
        router.root = viewController
        return viewController
    }
    
}

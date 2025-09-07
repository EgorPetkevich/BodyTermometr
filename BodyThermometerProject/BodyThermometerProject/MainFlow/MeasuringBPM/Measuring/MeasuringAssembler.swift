//
//  MeasuringAssembler.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 26.08.25.
//

import UIKit
import RxSwift

final class MeasuringAssembler {
    
    private init() {}
    
    static func assembly(
        container: Container,
        subject: PublishSubject<Int>? = nil,
    ) -> UIViewController {
        let router = MeasuringRouter(container: container, subject: subject)
        let alertService =
        MeasuringAlertServiceUseCase(alertService: AlertManagerService(container: container))
        let viewModel = MeasuringVM(router: router, alertService: alertService)
        let viewController = MeasuringVC(viewModel: viewModel)
        
        router.root = viewController
        return viewController
    }
    
}

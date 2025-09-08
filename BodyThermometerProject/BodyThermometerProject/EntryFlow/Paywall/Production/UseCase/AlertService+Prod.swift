//
//  AlertService+Prod.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 8.09.25.
//

import Foundation

struct PaywallProdAlertServiceUseCase: PaywallProdAlertServiceUseCaseProtocol {
    
    private let alertService: AlertManagerService
    
    init(alertService: AlertManagerService) {
        self.alertService = alertService
    }
    
    func showAlert(
        title: String,
        message: String,
        cancelTitle: String,
        okTitle: String,
        okHandler: @escaping () -> Void
    ) {
        alertService.showAlert(
            title: title,
            message: message,
            cancelTitle: cancelTitle,
            okTitle: okTitle,
            okHandler: okHandler
        )
    }
    
}

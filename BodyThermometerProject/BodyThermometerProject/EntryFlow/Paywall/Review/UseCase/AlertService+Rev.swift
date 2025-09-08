//
//  AlertService+Rev.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 7.09.25.
//

import Foundation

struct PaywallRevAlertServiceUseCase: PaywallRevAlertServiceUseCaseProtocol {
    
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

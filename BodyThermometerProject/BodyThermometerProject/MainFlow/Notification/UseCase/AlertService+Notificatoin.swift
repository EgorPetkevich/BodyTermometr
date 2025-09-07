//
//  AlertService+Notificatoin.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 7.09.25.
//

import Foundation

struct NotificationAlertServiceUseCase:
    NotificationAlertServiceUseCaseProtocol {
    
    private let alertService: AlertManagerService
    
    init(alertService: AlertManagerService) {
        self.alertService = alertService
    }
    
    func showError(
        title: String,
        message: String,
        goSettings: String,
        goSettingsHandler: @escaping () -> Void,
        cancelHandler: @escaping () -> Void
    ) {
        alertService.showAlert(title: title,
                               message: message,
                               cancelHandler: cancelHandler,
                               settingTitle: goSettings,
                               settingHandler: goSettingsHandler)
    }
    
}

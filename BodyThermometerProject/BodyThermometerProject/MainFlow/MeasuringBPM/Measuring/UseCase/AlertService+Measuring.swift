//
//  AlertService+Measuring.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 7.09.25.
//

import Foundation

final class MeasuringAlertServiceUseCase: MeasuringAlertManagerServiceUseCaseProtocol {
    
    private let alertService: AlertManagerService
    
    init(alertService: AlertManagerService) {
        self.alertService = alertService
    }
    
    
    func showCameraError(title: String,
                         message: String,
                         goSettings: String,
                         goSettingsHandler: @escaping () -> Void) {
        alertService.showAlert(title: title,
                               message: message,
                               settingTitle: goSettings,
                               settingHandler: goSettingsHandler)
    }
    
}

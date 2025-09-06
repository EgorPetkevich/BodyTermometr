//
//  AlertService+TempDetails.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 5.09.25.
//

import Foundation
import RxSwift
import RxCocoa

struct TempDetailsAlertManagerServiceUseCase:
    TempDetailsAlertManagerServiceUseCaseProtocol {
    
    private let alertServiceManager: AlertManagerService
    
    init(alertServiceManager: AlertManagerService) {
        self.alertServiceManager = alertServiceManager
    }
    
    func showActionSheetRx(
        firstTitle: String,
        secondTitle: String,
        cancelTitle: String
    ) -> Single<AlertManagerService.SheetChoice> {
        alertServiceManager
            .actionSheetRx(
                firstTitle: firstTitle,
                secondTitle: secondTitle,
                cancelTitle: cancelTitle
            )
    }
    
}


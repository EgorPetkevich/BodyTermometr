//
//  Alert+BPMDetails.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 4.09.25.
//

import Foundation
import RxSwift
import RxCocoa

struct BPMDetailsAlertManagerServiceUseCase:
    BPMDetailsAlertManagerServiceUseCaseProtocol {
    
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

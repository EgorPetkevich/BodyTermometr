//
//  KeyBoardHelperService+TemperatureInput.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 30.08.25.
//

import Foundation
import RxSwift

struct TemperatureInputKeyBoardHelperServiceUseCase:
    TemperatureInputKeyBoardHelperServiceUseCaseProtocol {
    
    var frame: Observable<CGRect> {
        return keyBoardHelperService.frame.asObservable()
    }
    
    private var keyBoardHelperService: KeyboardHelperService
    
    init(keyBoardHelperService: KeyboardHelperService) {
        self.keyBoardHelperService = keyBoardHelperService
    }
    
}

//
//  KeyBoardHelper+RegUseInfo.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 18.08.25.
//

import Foundation
import RxSwift

struct RegUserInfoKeyBoardHelperServiceUseCase:
    RegUserInfoKeyBoardHelperServiceUseCaseProtocol {
    
    var frame: Observable<CGRect> {
        return keyBoardHelperService.frame.asObservable()
    }
    
    private var keyBoardHelperService: KeyboardHelperService
    
    init(keyBoardHelperService: KeyboardHelperService) {
        self.keyBoardHelperService = keyBoardHelperService
    }
    
}

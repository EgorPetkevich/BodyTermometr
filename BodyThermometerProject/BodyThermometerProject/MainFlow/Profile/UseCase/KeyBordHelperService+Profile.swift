//
//  KeyBordHelperService+Profile.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 20.08.25.
//

import Foundation
import RxSwift

struct ProfileKeyBoardHelperServiceUseCase:
    ProfileKeyBoardHelperServiceUseCaseProtocol {
    
    var frame: Observable<CGRect> {
        return keyBoardHelperService.frame.asObservable()
    }
    
    private var keyBoardHelperService: KeyboardHelperService
    
    init(keyBoardHelperService: KeyboardHelperService) {
        self.keyBoardHelperService = keyBoardHelperService
    }
    
}

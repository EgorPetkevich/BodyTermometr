//
//  RealDataManager+Main.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 18.08.25.
//

import Foundation
import RxSwift
import RxCocoa

final class MainRealmDataManagerUseCase: MainRealmDataManagerUseCaseProtocol {

    var userInfo: Observable<UserInfoDTO> {
        realmDataManager.observeUserInfoDTO()
    }
    
    private let realmDataManager: RealmDataManager
    private let realmBPMManager: RealmBPMManager
    private let realmTempManager: RealmTempManager
        
    init(realmDataManager: RealmDataManager,
         realmBPMManager: RealmBPMManager,
         realmTempManager: RealmTempManager) {
        self.realmDataManager = realmDataManager
        self.realmBPMManager = realmBPMManager
        self.realmTempManager = realmTempManager
    }
    
    func getLastTemperature() -> Observable<Double?> {
        realmTempManager.getLastTemperature()
    }
    
    func getLastBPM() -> Observable<Int?> {
        realmBPMManager.getLastBPM()
    }
    
}

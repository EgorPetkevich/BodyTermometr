//
//  RealDataManager+RegUserInfo.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 18.08.25.
//

import Foundation

struct RegUserInfoRealDataManagerUseCase:
    RegUserInfoRealDataManagerUseCaseProtocol {
    
    private var realmDataManager: RealmDataManager
    
    init(realmDataManager: RealmDataManager) {
        self.realmDataManager = realmDataManager
    }
    
    func saveUserInfo(name: String, age: String) {
        realmDataManager.saveUserInfo(name: name, age: age)
    }
    
}

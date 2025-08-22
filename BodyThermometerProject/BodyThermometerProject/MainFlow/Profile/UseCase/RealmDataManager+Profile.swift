//
//  RealmDataManager+Profile.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 20.08.25.
//

import Foundation
import RxSwift
import RxCocoa

struct ProfileRealmDataManagerUseCase: ProfileRealmDataManagerUseCaseProtocol {
    
    var userInfo: Observable<UserInfoDTO> {
        realmDataManager.observeUserInfoDTO()
    }
    
    private let realmDataManager: RealmDataManager

    init(realmDataManager: RealmDataManager) {
        self.realmDataManager = realmDataManager
    }
    
    func saveUserInfo(name: String, age: String, gender: Gender) {
        realmDataManager.saveUserInfo(name: name, age: age, gender: gender)
    }
    
    func updateIconPath(_ iconPath: String) {
        realmDataManager.updateIconPath(iconPath)
    }
    
}

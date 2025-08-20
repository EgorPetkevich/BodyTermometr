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

    init(realmDataManager: RealmDataManager) {
        self.realmDataManager = realmDataManager
    }
    
}

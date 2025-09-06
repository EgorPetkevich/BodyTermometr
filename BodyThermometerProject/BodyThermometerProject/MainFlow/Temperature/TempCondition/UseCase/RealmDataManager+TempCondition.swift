//
//  RealmDataManager+TempCondition.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 1.09.25.
//

import Foundation
import RxSwift

struct TempConditionRealmDataManagerUseCase:
    TempConditionRealmDataManagerUseCaseProtocol {
    
    private let tempDataManage: RealmTempManager
    
    init(tempDataManage: RealmTempManager) {
        self.tempDataManage = tempDataManage
    }
    
    func save(dto: TempModelDTO) {
        tempDataManage.createOrUpdate(dto: dto)
    }
    
}

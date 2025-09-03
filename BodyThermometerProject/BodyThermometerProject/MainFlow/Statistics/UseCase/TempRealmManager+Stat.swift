//
//  TempRealmManager+Stat.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 2.09.25.
//

import Foundation
import RxSwift

struct StatisticsTempRealmManagerUseCase: StatisticsTempRealmManagerUseCaseProtocol {
        
    private let realmManager: RealmTempManager
    
    init(realmManager: RealmTempManager) {
        self.realmManager = realmManager
    }
    
    func observeAllSortedByDate() -> Observable<[TempModelDTO]?> {
        realmManager.observeAllSortedByDate()
    }
    
}

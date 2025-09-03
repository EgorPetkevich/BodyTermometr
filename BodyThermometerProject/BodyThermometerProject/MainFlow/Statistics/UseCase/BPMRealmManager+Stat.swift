//
//  BPMRealmManager+Stat.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 2.09.25.
//

import Foundation
import RxSwift

struct StatisticsBPMRealmManagerUseCase: StatisticsBPMRealmManagerUseCaseProtocol {
        
    private let realmManager: RealmBPMManager
    
    init(realmManager: RealmBPMManager) {
        self.realmManager = realmManager
    }
    
    func observeAllSortedByDate() -> Observable<[BPMModelDTO]?> {
        realmManager.observeAllSortedByDate()
    }
    
}

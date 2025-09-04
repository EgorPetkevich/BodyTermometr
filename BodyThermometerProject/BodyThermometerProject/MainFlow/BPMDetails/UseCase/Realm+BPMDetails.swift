//
//  Realm+BPMDetails.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 4.09.25.
//

import Foundation

struct BPMDetailsRealmBPMManagerUseCase:
    BPMDetailsRealmBPMManagerUseCaseProtocol {
    
    private let bpmRealmManager: RealmBPMManager
    
    init(bpmRealmManager: RealmBPMManager) {
        self.bpmRealmManager = bpmRealmManager
    }
    
    func deleteDTO(_ dto: BPMModelDTO) {
        bpmRealmManager.delete(dto: dto)
    }
    
    func updateDTO(_ dto: BPMModelDTO) {
        bpmRealmManager.createOrUpdate(dto: dto)
    }
    
}

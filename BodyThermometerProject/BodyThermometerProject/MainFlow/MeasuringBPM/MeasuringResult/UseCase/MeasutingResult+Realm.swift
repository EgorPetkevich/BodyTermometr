//
//  MeasutingResult+Realm.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 29.08.25.
//

import Foundation

struct MeasuringResultRealmBPMManagerUseCase:
    MeasuringResultRealmBPMManagerUseCaseProtocol {

    private let realm: RealmBPMManager
    
    init(realm: RealmBPMManager) {
        self.realm = realm
    }
    
    func saveBPM(bpm: Int, activity: String?, notesText: String?) {
        let dto = BPMModelDTO(id: UUID().uuidString,
                              date: .now,
                              bpm: bpm,
                              activity: activity,
                              notesText: notesText)
        realm.createOrUpdate(dto: dto)
    }
    
}


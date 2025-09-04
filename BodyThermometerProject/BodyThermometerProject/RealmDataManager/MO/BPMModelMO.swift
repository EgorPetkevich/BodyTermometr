//
//  BPMModel.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 29.08.25.
//

import Foundation
import RealmSwift

final class BPMModelMO: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var date: Date
    @Persisted var bpm: Int
    @Persisted var activity: String?
    @Persisted var notesText: String?
    
    func toDTO() -> (BPMModelDTO) {
        return BPMModelDTO.fromMO(self)
    }
    
    func apply(dto: BPMModelDTO) {
        self.date = dto.date
        self.bpm = dto.bpm
        self.activity = dto.activity
        self.notesText = dto.notesText
    }
    
}

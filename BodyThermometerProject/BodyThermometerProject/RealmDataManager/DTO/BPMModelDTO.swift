//
//  BPMDTO.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 29.08.25.
//

import Foundation
import RealmSwift

struct BPMModelDTO: Equatable {
    var id: String
    var date: Date
    var bpm: Int
    var activity: String?
    var notesText: String?

    init(id: String,
         date: Date,
         bpm: Int,
         activity: String? = nil,
         notesText: String? = nil) {
        self.id = id
        self.date = date
        self.bpm = bpm
        self.activity = activity
        self.notesText = notesText
    }
    
    static public func fromMO(_ mo: BPMModelMO) -> BPMModelDTO {
        
        return BPMModelDTO(id: mo.id,
                           date: mo.date,
                           bpm: mo.bpm,
                           activity: mo.activity,
                           notesText: mo.notesText)
    }
    
    func createMO(realm: Realm) -> BPMModelMO {
        let BPMModelMO = BPMModelMO()
        BPMModelMO.apply(dto: self)
        do {
            try realm.write {
                realm.add(BPMModelMO, update: .all)
            }
        } catch {
            print("[Error] Failed to save object: \(error)")
        }
        return BPMModelMO
    }
    
    public func apply(to mo: BPMModelMO) {
            mo.date = self.date
            mo.bpm = self.bpm
            mo.activity = self.activity
            mo.notesText = self.notesText
    }
    
}

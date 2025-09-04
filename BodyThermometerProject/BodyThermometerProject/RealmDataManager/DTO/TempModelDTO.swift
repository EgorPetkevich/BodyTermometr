//
//  TempModelDTO.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 1.09.25.
//

import Foundation
import RealmSwift

struct TempModelDTO: Equatable {
    var id: String
    var date: Date
    var temp: Double
    var unit: String
    var measureSite: String?
    var symptoms:  [String]
    var feeling: String?
    var notesText: String?
    
    init(id: String,
         date: Date,
         temp: Double,
         unit: String,
         measureSite: String? = nil,
         symptoms: [String] = [],
         feeling: String? = nil,
         notesText: String? = nil) {
        self.id = id
        self.date = date
        self.temp = temp
        self.unit = unit
        self.measureSite = measureSite
        self.symptoms = symptoms
        self.feeling = feeling
        self.notesText = notesText
    }
    
    static public func fromMO(_ mo: TempModelMO) -> TempModelDTO {
        return TempModelDTO(id: mo.id,
                            date: mo.date,
                            temp: mo.temp,
                            unit: mo.unit,
                            measureSite: mo.measureSite,
                            symptoms: Array(mo.symptoms),
                            feeling: mo.feeling,
                            notesText: mo.notesText)
    }
    
    func createMO(realm: Realm) -> TempModelMO {
        let model = TempModelMO()
        model.apply(dto: self)
        do {
            try realm.write {
                realm.add(model, update: .all)
            }
        } catch {
            print("[Error] Failed to save object: \(error)")
        }
        return model
    }
    
    public func apply(to mo: TempModelMO) {
        mo.date = self.date
        mo.temp = self.temp
        mo.unit = self.unit
        mo.measureSite = self.measureSite
        mo.symptoms.removeAll()
        mo.symptoms.append(objectsIn: self.symptoms)
        mo.feeling = self.feeling
        mo.notesText = self.notesText
    }
    
}

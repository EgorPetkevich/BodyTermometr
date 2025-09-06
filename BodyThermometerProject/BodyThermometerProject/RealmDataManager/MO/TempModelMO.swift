//
//  TempModel.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 1.09.25.
//

import Foundation
import RealmSwift

final class TempModelMO: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var date: Date
    @Persisted var temp: Double
    @Persisted var unit: String
    @Persisted var measureSite: String
    @Persisted var symptoms:  List<String>
    @Persisted var feeling: String?
    @Persisted var notesText: String?
    
    func toDTO() -> (TempModelDTO) {
        return TempModelDTO.fromMO(self)
    }
    
    func create(dto: TempModelDTO) {
        self.id = dto.id
        self.date = dto.date
        self.temp = dto.temp
        self.unit = dto.unit
        self.measureSite = dto.measureSite
        self.symptoms.removeAll()
        self.symptoms.append(objectsIn: dto.symptoms)
        self.feeling = dto.feeling
        self.notesText = dto.notesText
    }
    
    func apply(dto: TempModelDTO) {
        self.date = dto.date
        self.temp = dto.temp
        self.unit = dto.unit
        self.measureSite = dto.measureSite
        self.symptoms.removeAll()
        self.symptoms.append(objectsIn: dto.symptoms)
        self.feeling = dto.feeling
        self.notesText = dto.notesText
    }
    
}

//
//  Speciment.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 29.06.25.
//

import Foundation
import RealmSwift

@objcMembers class Specimen: Object {
    
    dynamic var category: Category!
    
    dynamic var name = ""
    dynamic var specimenDescription = ""
    dynamic var latitude = 0.0
    dynamic var longitude = 0.0
//    @Persisted var created = NSDate()
}



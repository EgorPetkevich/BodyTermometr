//
//  Category.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 29.06.25.
//

import Foundation
import RealmSwift
 
@objcMembers class Category : Object {
    @Persisted(primaryKey: true) var id: UUID = UUID()
    @Persisted var name = ""
}

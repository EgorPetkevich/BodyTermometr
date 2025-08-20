//
//  Gender.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 18.08.25.
//

import Foundation
import RealmSwift

enum Gender: String, PersistableEnum {
    case female
    case male

    var icon: UIImage {
        switch self {
        case .female: return .regFemale
        case .male: return .regMale
        }
    }
}

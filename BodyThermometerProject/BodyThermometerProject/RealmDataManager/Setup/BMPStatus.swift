//
//  BMPStatus.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 28.08.25.
//

import UIKit

enum BPMStatus {
    case slow
    case normal
    case fast

    init(bpm: Int) {
        switch bpm {
        case ..<60:
            self = .slow
        case 60...100:
            self = .normal
        default:
            self = .fast
        }
    }
    
    var title: String {
        switch self {
        case .slow:   return "Slow"
        case .normal: return "Normal"
        case .fast:   return "Fast"
        }
    }

    var color: UIColor {
        switch self {
        case .slow:   return .appYellow
        case .normal: return .appGreen
        case .fast:   return .appRed
        }
    }
    
}

//
//  TemperatureStatus.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 30.08.25.
//

import UIKit

enum TemperatureStatus {
    
    case hypothermia
    case normal
    case lowGradeFever
    case fever
    case hyperpyrexia

    init(value: Double, unit: TemperatureUnit) {
        let tempC: Double
        switch unit {
        case .celsius:
            tempC = value
        case .fahrenheit:
            tempC = (value - 32.0) * 5.0 / 9.0
        }
        switch tempC {
        case ..<35.5:
            self = .hypothermia
        case 35.5...37.5:
            self = .normal
        case 37.5...38.4:
            self = .lowGradeFever
        case 38.5...39.9:
            self = .fever
        case 40...:
            self = .hyperpyrexia
        default:
            self = .normal
        }
    }
    
    var title: String {
        switch self {
        case .hypothermia:
            "Hypothermia"
        case .normal:
            "Normal"
        case .lowGradeFever:
            "Low-grade Fever"
        case .fever:
            "Fever"
        case .hyperpyrexia:
            "Hyperpyrexia"
        }
    }

    var color: UIColor {
        switch self {
        case .hypothermia: .appPurple
        case .normal: .appGreen
        case .lowGradeFever: .appGold
        case .fever: .appBlue
        case .hyperpyrexia: .appRed
        }
    }
    
}

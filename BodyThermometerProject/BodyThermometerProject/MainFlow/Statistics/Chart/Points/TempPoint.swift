//
//  TempPoint.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 3.09.25.
//

import UIKit

struct TempPoint {
    let valueC: Double
    let date: Date
    var color: UIColor = UIColor()
    init(valueC: Double,
         date: Date) {
        self.valueC = valueC
        self.date = date
        self.color = TempPoint.getColor(from: valueC)
    }
    
    static func getColor(from temp: Double) -> UIColor {
        switch temp {
        case ..<35.5:
            return .appPurple
        case 35.5...37.5:
            return .appGreen
        case 37.6...38.4:
            return .appGold
        case 38.5...39.9:
            return .appBlue
        case let x where x >= 40.0:
            return .appRed
        default:
            return .gray
        }
    }
    
    static func getDescription(from temp: Double) -> String {
        switch temp {
        case ..<35.5:
            return "Hypothermia"
        case 35.5...37.5:
            return "Normal"
        case 37.6...38.4:
            return "Low-grade Fever"
        case 38.5...39.9:
            return "Fever"
        case let x where x >= 40.0:
            return "Hyperpyrexia"
        default:
            return ""
        }
    }
}

//
//  IntGuideTempSection.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 3.09.25.
//

import UIKit

final class IntGuideTempSection {
    
    enum IntGuideTemp: CaseIterable, IntGuideCellProtocol {
        
        case hypothermia
        case normal
        case lowGradeFever
        case fever
        case hyperpyrexia
        
        var statusColor: UIColor {
            switch self {
            case .hypothermia: return .appPurple
            case .normal: return .appGreen
            case .lowGradeFever: return .appGold
            case .fever: return .appBlue
            case .hyperpyrexia: return .appRed
            }
           
        }
        
        
        var statusText: String {
            switch self {
            case .hypothermia: return "Hypothermia"
            case .normal: return "Normal"
            case .lowGradeFever: return "Low-grade Fever"
            case .fever: return "Fever"
            case .hyperpyrexia: return "Hyperpyrexia"
            }
        }

        
        func valueText(_ unit: TempUnit?) -> String {
            guard let unit else { return ""}
            switch unit {
            case .c:
                switch self {
                case .hypothermia: return "< 35,5°C"
                case .normal: return "35,5–37,5°C"
                case .lowGradeFever: return "37,6–38,4°C"
                case .fever: return "38,5–39,9°C"
                case .hyperpyrexia: return "≥ 40.0°C"
                }
            case .f:
                switch self {
                case .hypothermia: return "< 95.9°F"
                case .normal: return "96.0–99.5°F"
                case .lowGradeFever: return "99.6–101.1°F"
                case .fever: return "101.2–103.8°F"
                case .hyperpyrexia: return "≥ 104.0°F"
                }
            }
        }
    }
    
}

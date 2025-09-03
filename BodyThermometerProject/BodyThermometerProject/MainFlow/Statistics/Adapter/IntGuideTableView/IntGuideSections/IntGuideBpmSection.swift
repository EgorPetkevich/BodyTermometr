//
//  IntGuideBpmSection.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 3.09.25.
//

import UIKit

final class IntGuideBpmSection {
    
    enum IntGuideBpm: CaseIterable, IntGuideCellProtocol {
        
        case bradycardia
        case belowAverage
        case normal
        case elevated
        case high
        
        var statusColor: UIColor {
            switch self {
            case .bradycardia: return .appPurple
            case .belowAverage: return .appPink
            case .normal: return .appGreen
            case .elevated: return .appBlue
            case .high: return .appRed
            }
           
        }
        
        
        var statusText: String {
            switch self {
            case .bradycardia: return "Bradycardia (Low heart rate)"
            case .belowAverage: return "Below Average"
            case .normal: return "Normal"
            case .elevated: return "Elevated (Tachycardia)"
            case .high: return "Elevated (Tachycardia)"
            }
        }
        
        func valueText(_ unit: TempUnit?) -> String {
            switch self {
            case .bradycardia: return "< 50 bpm"
            case .belowAverage: return "50–59 bpm"
            case .normal: return "60–100 bpm"
            case .elevated: return "101–120 bpm"
            case .high: return "> 120 bpm "
            }
        }
    }
    
}

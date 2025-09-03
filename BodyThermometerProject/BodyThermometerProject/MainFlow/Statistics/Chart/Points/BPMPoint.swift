//
//  BPMPoint.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 3.09.25.
//

import UIKit

struct BPMPoint {
    let bpm: Int16
    let date: Date
    var color: UIColor = UIColor()
    init(bpm: Int16,
         date: Date) {
        self.bpm = bpm
        self.date = date
        self.color = BPMPoint.getColor(from: bpm)
    }
    
    static func getColor(from bmp: Int16) -> UIColor {
        switch bmp {
        case ..<50:
            return .appPurple
        case 50...59:
            return .appPink
        case 60...100:
            return .appGreen
        case 101...120:
            return .appBlue
        case let x where x > 120:
            return .appRed
        default:
            return .gray
        }
    }
    
    static func getDescription(from bmp: Int16) -> String {
        switch bmp {
        case ..<50:
            return "Bradycardia (Low heart rate)"
        case 50...59:
            return "Below Average"
        case 60...100:
            return "Normal"
        case 101...120:
            return "Elevated (Tachycardia)"
        case let x where x > 120:
            return "High (Possible concern)"
        default:
            return ""
        }
    }
}

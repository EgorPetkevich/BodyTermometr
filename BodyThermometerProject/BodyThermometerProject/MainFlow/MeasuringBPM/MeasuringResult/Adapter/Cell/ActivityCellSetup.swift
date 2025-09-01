//
//  ActivityCellSetup.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 28.08.25.
//

import UIKit

enum Activity: CaseIterable {
    case normal, resting, walking, exercise

    var title: String {
        switch self {
        case .normal:   return "Normal"
        case .resting:  return "Resting"
        case .walking:  return "Walking"
        case .exercise: return "Exercise"
        }
    }
    var image: UIImage {
        switch self {
        case .normal:   return .measuringActNormal
        case .resting:  return .measuringActResting
        case .walking:  return .measuringActWalking
        case .exercise: return .measuringActExercise
        }
    }
}

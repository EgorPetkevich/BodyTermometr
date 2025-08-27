//
//  MeasuringGuideRouter.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 26.08.25.
//

import UIKit

final class MeasuringGuideRouter: MeasuringGuideRouterProtocol {
    
    weak var root: UIViewController?
    
    func dismiss() {
        root?.dismiss(animated: true)
    }
}

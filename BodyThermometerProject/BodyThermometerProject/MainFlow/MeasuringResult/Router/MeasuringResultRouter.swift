//
//  MeasuringResultRouter.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 27.08.25.
//

import UIKit

final class MeasuringResultRouter: MeasuringResultRouterProtocol {
    
    weak var root: UIViewController?
    
    func dismiss() {
        root?.dismiss(animated: true)
    }
    
    func openMain() {
        root?.navigationController?.popToRootViewController(animated: true)
    }
    
}

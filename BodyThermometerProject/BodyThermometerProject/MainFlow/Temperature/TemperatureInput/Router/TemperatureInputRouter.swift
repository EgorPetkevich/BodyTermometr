//
//  TemperatureInputRouter.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 30.08.25.
//

import UIKit

final class TemperatureInputRouter: TemperatureInputRouterProtocol {
    
    weak var root: UIViewController?
    
    private let container: Container
    
    init(container: Container) {
        self.container = container
    }
    
    func openTempCondition(temperature: Double, unit: TemperatureUnit) {
        let vc = TempConditionAssembler.assembly(container: container,
                                                 temp: temperature,
                                                 unit: unit)
        root?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func dismiss() {
        root?.navigationController?.popViewController(animated: true)
    }
    
}

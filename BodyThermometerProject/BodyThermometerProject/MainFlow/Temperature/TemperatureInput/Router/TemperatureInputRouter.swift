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
    private let dto: TempModelDTO?
    
    init(container: Container, _ dto: TempModelDTO? = nil) {
        self.container = container
        self.dto = dto
    }
    
    func openTempCondition(temperature: Double, unit: TempUnit) {
        let vc = TempConditionAssembler.assembly(container: container,
                                                 temp: temperature,
                                                 unit: unit,
                                                 dto
        )
        root?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func dismiss() {
        root?.navigationController?.popViewController(animated: true)
    }
    
}

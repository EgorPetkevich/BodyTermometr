//
//  StatisticsRouter.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 1.09.25.
//

import UIKit

final class StatisticsRouter: StatisticsRouterProtocol {
    
    weak var root: UIViewController?
    
    private let container: Container
    
    init(container: Container) {
        self.container = container
    }
    
    func dismiss() {
        root?.navigationController?.popViewController(animated: true)
    }
    
}

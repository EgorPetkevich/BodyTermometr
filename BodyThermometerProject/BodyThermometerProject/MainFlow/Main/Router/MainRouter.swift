//
//  MainRouter.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 18.08.25.
//

import UIKit

final class MainRouter: MainRouterProtocol {
    
    weak var root: UIViewController?
    
    private let container: Container
    
    init(container: Container) {
        self.container = container
    }
    
}

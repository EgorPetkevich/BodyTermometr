//
//  ProfileRouter.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 20.08.25.
//

import UIKit

final class ProfileRouter: ProfileRouterProtocol {
    
    weak var root: UIViewController?
    
    private let container: Container
    
    init(container: Container) {
        self.container = container
    }
    
    func dismiss() {
        root?.dismiss(animated: true)
    }
    
}

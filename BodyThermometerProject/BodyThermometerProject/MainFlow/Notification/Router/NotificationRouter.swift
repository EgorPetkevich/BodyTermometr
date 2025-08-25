//
//  NotificationRouter.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 25.08.25.
//

import UIKit

final class NotificationRouter: NotificationRouterProtocol {
    
    weak var root: UIViewController?
    
    func dismiss() {
        root?.dismiss(animated: true)
    }
    
}

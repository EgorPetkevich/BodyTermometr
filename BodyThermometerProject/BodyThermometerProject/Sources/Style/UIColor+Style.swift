//
//  UIColor+Style.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 17.08.25.
//

import UIKit

extension UIColor {
    
    func alpa(_ alha: CGFloat) -> UIColor {
        return self.withAlphaComponent(alha)
    }
}

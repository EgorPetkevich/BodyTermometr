//
//  UIIMageView+Style.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 19.08.25.
//

import UIKit

extension UIImageView {
    
    @discardableResult
    func setBgColor(_ color: UIColor) -> UIImageView {
        self.backgroundColor = color
        return self
    }
    
}

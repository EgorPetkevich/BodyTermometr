//
//  UIView+Layer.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 13.08.25.
//

import UIKit

extension UIView {
    
    var radius: CGFloat {
        get { layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
    
}

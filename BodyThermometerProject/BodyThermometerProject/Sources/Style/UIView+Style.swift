//
//  UIView+Style.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 13.08.25.
//

import UIKit

extension UIView {
        
    static func simpleView(color: UIColor) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        return view
    }
    
    @discardableResult
    func bgColor(_ color: UIColor) -> UIView {
        self.backgroundColor = color
        return self
    }
    
    @discardableResult
    func cornerRadius(_ radius: CGFloat) -> UIView {
        self.radius = radius
        return self
    }
    
}

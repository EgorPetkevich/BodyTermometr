//
//  UILabel+Set.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 13.08.25.
//

import UIKit

extension UILabel {
    
    @discardableResult
    func numOfLines(_ lines: Int) -> UILabel {
        self.numberOfLines = lines
        return self
    }
    
    @discardableResult
    func textAlignment(_ alignment: NSTextAlignment) -> UILabel {
        self.textAlignment = alignment
        return self
    }

}

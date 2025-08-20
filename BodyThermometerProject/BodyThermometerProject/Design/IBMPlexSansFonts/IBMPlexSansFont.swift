//
//  Font+Utils.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 13.08.25.
//

import UIKit

extension UIFont {
    
    static func appRegularFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "IBMPlexSans-Regular", size: size)!
    }
    
    static func appSemiBoldFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "IBMPlexSans-SemiBold", size: size)!
    }
    
    static func appMediumFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "IBMPlexSans-Medium", size: size)!
    }
    
}

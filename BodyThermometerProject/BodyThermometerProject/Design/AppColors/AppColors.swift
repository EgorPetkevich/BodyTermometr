//
//  UIColor+Const.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 13.08.25.
//

import UIKit

extension UIColor {
    
    convenience init(_ r: UInt8, _ g: UInt8, _ b: UInt8, _ a: CGFloat) {
        self.init(red: CGFloat(r) / 255.0,
                  green: CGFloat(g) / 255.0,
                  blue: CGFloat(b) / 255.0,
                  alpha: a)
    }
    //Colors
    static let appWhite: UIColor = .init(255, 255, 255, 1)
    static let appBlack: UIColor = .init(40, 40, 40, 1)
    static let appGrey: UIColor = .init(108, 112, 114, 1)
    static let appLightGrey: UIColor = .init(247, 247, 247, 1)
    static let appYellow: UIColor = .init(211, 198, 77, 1)
    static let appGreen: UIColor = .init(77, 211, 140, 1)
    static let appRed: UIColor = .init(233, 73, 73, 1)
    static let appPurple: UIColor = .init(104, 77, 211, 1)
    static let appGold: UIColor = .init(211, 198, 77, 1)
    static let appBlue: UIColor = .init(77, 131, 211, 1)
    
    static let appBg: UIColor = .init(229, 236, 238, 1)
    static let appButton: UIColor = .init(99, 208, 247, 1)
    static let appBgBlur: UIColor = .init(255, 255, 255, 0.01)
}

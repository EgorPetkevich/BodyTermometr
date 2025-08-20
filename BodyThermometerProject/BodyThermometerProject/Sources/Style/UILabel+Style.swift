//
//  UILabel+Utils.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 13.08.25.
//

import UIKit

extension UILabel {
    
    static func titleLabel(
        withText text: String,
        font: UIFont,
        color: UIColor? = .appBlack
    ) -> UILabel {
        let label = UILabel()
        label.font = font
        label.textColor = color
        label.text = text
        return label
    }
    
    static func semiBoldTitleLabel(
        withText text: String,
        ofSize size: CGFloat,
        color: UIColor? = .appBlack
    ) -> UILabel {
        return titleLabel(withText: text,
                          font: UIFont.appSemiBoldFont(ofSize: size),
                          color: color)
    }
    
    static func regularTitleLabel(
        withText text: String,
        ofSize size: CGFloat,
        color: UIColor? = .appBlack
    ) -> UILabel {
        return titleLabel(withText: text,
                          font: UIFont.appRegularFont(ofSize: size),
                          color: color)
    }
    
    static func mediumTitleLabel(
        withText text: String,
        ofSize size: CGFloat,
        color: UIColor? = .appBlack
    ) -> UILabel {
        return titleLabel(withText: text,
                          font: UIFont.appMediumFont(ofSize: size),
                          color: color)
    }
    
}

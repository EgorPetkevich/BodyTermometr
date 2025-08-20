//
//  UIButton+Style.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 14.08.25.
//

import UIKit

extension UIButton {
    
    static func systemButton(
        title: String,
        font: UIFont,
        tint: UIColor
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = font
        button.tintColor = tint
        return button
    }
    
    static func footerActionButton(title: String) -> UIButton {
        systemButton(title: title,
                     font: .appRegularFont(ofSize: 12.0),
                     tint: .appBlack.withAlphaComponent(0.6))
    }
    
    static func crossButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(.crossIconGrey, for: .normal)
        button.tintColor = .appGrey.withAlphaComponent(0.5)
        return button
    }
    
    @discardableResult
    func setTitle(_ text: String) -> UIButton {
        self.setTitle(text, for: .normal)
        return self
    }
    
    @discardableResult
    func setImage(_ image: UIImage) -> UIButton {
        self.setImage(image, for: .normal)
        return self
    }
    
    @discardableResult
    func setTintColor(_ color: UIColor) -> UIButton {
        self.tintColor = color
        return self
    }
    
    @discardableResult
    func setBgColor(_ color: UIColor) -> UIButton {
        self.backgroundColor = color
        return self
    }
    
}

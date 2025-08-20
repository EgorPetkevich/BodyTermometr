//
//  RegistrationPageControl+Setup.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 17.08.25.
//

import UIKit

extension RegistrationPageControlView {
    
    @discardableResult
    func setup(currentPage: Int) -> RegistrationPageControlView {
        self.currentPage = currentPage
        return self
    }
    
}

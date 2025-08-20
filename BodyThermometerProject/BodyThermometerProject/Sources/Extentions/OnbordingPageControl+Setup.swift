//
//  OnbordingPageControl+Setup.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 13.08.25.
//

import UIKit

extension OnboardingPageControlView {
    
    @discardableResult
    func setup(currentPage: Int) -> OnboardingPageControlView {
        self.currentPage = currentPage
        return self
    }
    
}

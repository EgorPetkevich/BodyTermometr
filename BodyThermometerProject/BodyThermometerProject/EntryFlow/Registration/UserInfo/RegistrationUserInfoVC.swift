//
//  RegistrationUserInfoVC.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 17.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class RegnUserInfoVC: UIViewController {
    
    private enum TextConst {
        static let titleText: String = "What’s your name and age?"
    }
    
    private lazy var pageControlView: RegistrationPageControlView =
    RegistrationPageControlView()
    
    private lazy var titleLabel: UILabel =
        .mediumTitleLabel(withText: TextConst.titleText, ofSize: 24.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

//MARK: - Private
private extension RegnUserInfoVC {
    
    func setupSnapKitConstrains() {
        
    }
    
}

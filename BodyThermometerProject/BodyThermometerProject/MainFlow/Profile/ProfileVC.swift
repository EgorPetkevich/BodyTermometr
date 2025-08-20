//
//  ProfileVC.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 20.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class ProfileVC: UIViewController {
    
    private enum TextConst {
        static let titleText: String = "Profile"
        static let choosePhotoText: String = "Choose photo"
    }
    
    private lazy var titleLabel: UILabel =
        .mediumTitleLabel(withText: TextConst.titleText, ofSize: 24.0)
    
    private lazy var backButton: UIButton =
    UIButton(type: .system)
        .setImage(.arrowLeftIcon)
        .setBgColor(.appWhite)
    
    private lazy var userIconView: ProfileUserIconView = ProfileUserIconView()
    
    private lazy var choosePhotoButton: UIButton =
    UIButton(type: .system)
        .setImage(.cameraIcon)
        .setTitle(TextConst.choosePhotoText)
        .setTintColor(.appBlack)
    
    private lazy var userNameTextFieldView: ProfileTextFiledView =
    ProfileTextFiledView(type: .name)
    
    private lazy var userAgeTextFieldView: ProfileTextFiledView =
    ProfileTextFiledView(type: .age())
    
//    private lazy var userGenderCellsView:
    
}

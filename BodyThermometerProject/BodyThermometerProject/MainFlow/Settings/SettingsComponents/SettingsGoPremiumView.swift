//
//  SettingsGoPremiumView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 25.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class SettingsGoPremiumView: UIView {

    private enum TextConst {
        static let titleText: String = "💎 Go Premium"
        static let subTitleText: String = "Enjoy unlimited tracking, detailed stats, \nand exclusive tools for your health."
        static let upgradeButtonText: String = "Upgrade"
    }
    
    private enum LayoutConst {
        static let height: CGFloat = 82.0
        static let radius: CGFloat = 16.0
        static let upgradeButtonSize: CGSize = .init(width: 108, height: 40.0)
    }
    
    private lazy var titleLabel: UILabel =
        .mediumTitleLabel(withText: TextConst.titleText,
                          ofSize: 18.0,
                          color: .appWhite)
    
    private lazy var subTitleLabel: UILabel =
        .regularTitleLabel(withText: TextConst.subTitleText,
                           ofSize: 12.0,
                           color: .appWhite)
        .numOfLines(2)
    
    private lazy var upgradeButton: UIButton =
    UIButton(type: .system)
        .setTitle(TextConst.upgradeButtonText)
        .setFont(.appSemiBoldFont(ofSize: 14.0))
        .setBgColor(.appButton)
        .setTintColor(.appBlack)
    
    var tap: Observable<Void> {
        upgradeButton.rx.tap.asObservable()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupSnapKitConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//MARK: - Private
private extension SettingsGoPremiumView {
    
    func commonInit() {
        self.backgroundColor = .appBlack
        self.addSubview(titleLabel)
        self.addSubview(subTitleLabel)
        self.addSubview(upgradeButton)
    }
    
    func setupSnapKitConstraints() {
        self.snp.makeConstraints { make in
            make.height.equalTo(LayoutConst.height)
        }
        self.radius = LayoutConst.radius
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(14.0)
            make.left.equalToSuperview().inset(16.0)
        }
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4.0)
            make.left.equalToSuperview().inset(16.0)
        }
        upgradeButton.snp.makeConstraints { make in
            make.size.equalTo(LayoutConst.upgradeButtonSize)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(16.0)
        }
        upgradeButton.radius = LayoutConst.upgradeButtonSize.height / 2
    }
    
}

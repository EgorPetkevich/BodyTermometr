//
//  RegistrationPageControlView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 17.08.25.
//

import UIKit
import SnapKit

final class RegistrationPageControlView: UIView {
    
    private enum Constants {
        static let pageIndicatorHeight: CGFloat = 10.0
        static let cornerRadius: CGFloat = 5.0
    }
    
    private lazy var firstPageView: UIView =
    UIView()
        .bgColor(.appWhite)
        .cornerRadius(Constants.cornerRadius)
    
    private lazy var secondPageView: UIView =
    UIView()
        .bgColor(.appWhite)
        .cornerRadius(Constants.cornerRadius)
    
    private var _currentPage: Int = 0
    var currentPage: Int {
        get { _currentPage }
        set {
            _currentPage = max(0, min(newValue, 1))
            updateColors()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupSnapKitConstraints()
        updateColors()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private
private extension RegistrationPageControlView {
    
    func commonInit() {
        addSubview(firstPageView)
        addSubview(secondPageView)
    }
    
    func setupSnapKitConstraints() {
        snp.makeConstraints { make in
            make.height.equalTo(Constants.pageIndicatorHeight)
        }
        
        firstPageView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalTo(self.snp.centerX).offset(-2.0)
            make.centerY.equalToSuperview()
            make.height.equalTo(Constants.pageIndicatorHeight)
        }
        
        secondPageView.snp.makeConstraints { make in
            make.left.equalTo(self.snp.centerX).offset(2.0)
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(Constants.pageIndicatorHeight)
        }
    }
    
    func updateColors() {
        firstPageView.backgroundColor =
        (currentPage == 0) ? .appButton : .appButton
        secondPageView.backgroundColor =
        (currentPage == 1) ? .appButton : .appWhite
    }
}

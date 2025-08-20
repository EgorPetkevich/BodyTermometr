//
//  OnboardingNextPageButton.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 13.08.25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ContinueButtonView: UIView {
    
    private enum Constants {
        static let title: String = "Continue"
        static let titleColor: UIColor = .appBlack
        static let backgroundColor: UIColor = .appButton
    }
    
    private enum ButtonParams {
        static let buttonHeight: CGFloat = 64.0
        static let buttonCornerRadius: CGFloat = 32.0
        static let arrowViewSize: CGFloat = 48.0
        static let arrowViewRadius: CGFloat = 24.0
    }
    
    var tap: Observable<Void> {
        coverButton.rx.tap.asObservable()
    }
    
    private lazy var coverButton: UIButton = UIButton()
    private lazy var mainTitleLabel: UILabel =
        .semiBoldTitleLabel(withText: Constants.title, ofSize: 14.0)
    private lazy var arrowView: UIView = .simpleView(color: .black)
    private lazy var arrowImageView: UIImageView = UIImageView(image: .arrowIcon)
    
    private let bag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupSnapkitConstraints()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        coverButton.rx.controlEvent(.touchDown)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.alpha = 0.7
                }
            })
            .disposed(by: bag)
        
        coverButton.rx.controlEvent(
            [.touchUpInside,
            .touchUpOutside,
            .touchCancel])
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.alpha = 1.0
                }
            })
            .disposed(by: bag)
    }
}

// MARK: - Private
private extension ContinueButtonView {
    
    func commonInit() {
        backgroundColor = .appButton
        
        addSubview(coverButton)
        coverButton.layer.zPosition = .greatestFiniteMagnitude
        
        addSubview(mainTitleLabel)
        addSubview(arrowView)
        arrowView.addSubview(arrowImageView)
    }
    
    func setupSnapkitConstraints() {
        coverButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        snp.makeConstraints { make in
            make.height.equalTo(ButtonParams.buttonHeight)
        }
        radius = ButtonParams.buttonCornerRadius
        
        mainTitleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        arrowView.snp.makeConstraints { make in
            make.size.equalTo(ButtonParams.arrowViewSize)
            make.right.equalToSuperview().inset(8.0)
            make.centerY.equalToSuperview()
        }
        arrowView.radius = ButtonParams.arrowViewRadius
        
        arrowImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
}

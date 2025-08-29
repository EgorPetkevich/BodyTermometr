//
//  SaveButtonView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 28.08.25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SaveButtonView: UIView {
    
    private enum Constants {
        static let title: String = "Save"
        static let titleColor: UIColor = .appBlack
        static let backgroundColor: UIColor = .appButton
    }
    
    private enum ButtonParams {
        static let buttonHeight: CGFloat = 64.0
        static let buttonCornerRadius: CGFloat = 32.0
    }
    
    var tap: Observable<Void> {
        coverButton.rx.tap.asObservable()
    }
    
    private lazy var coverButton: UIButton = UIButton()
    private lazy var mainTitleLabel: UILabel =
        .semiBoldTitleLabel(withText: Constants.title, ofSize: 14.0)
    
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
private extension SaveButtonView {
    
    func commonInit() {
        addSubview(mainTitleLabel)
        backgroundColor = .appButton
        addSubview(coverButton)
        coverButton.layer.zPosition = .greatestFiniteMagnitude
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
    
    }
    
}


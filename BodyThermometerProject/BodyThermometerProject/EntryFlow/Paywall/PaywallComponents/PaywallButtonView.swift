//
//  PaywallButtonView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 15.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class PaywallButtonView: UIView {
    
    private enum TextConst {
        static let subTitleText: String = "Auto renewable. Cancel anytime"
        static let titleColor: UIColor = .appBlack
        static let backgroundColor: UIColor = .appButton
        
        static func getSubTitleText(with price: String) -> String {
            "Subscribe for \(price)/week"
        }
        static func getTrialSubTitleText(with price: String) -> String {
            "Try 3-Day Trial, then \(price)/week"
        }
    }
    
    private enum ButtonParams {
        static let buttonHeight: CGFloat = 64.0
        static let buttonCornerRadius: CGFloat = 32.0
        static let arrowViewSize: CGFloat = 48.0
        static let arrowViewRadius: CGFloat = 24.0
    }
    
    var isTrialRelay: BehaviorRelay<Bool> = .init(value: false)
    var subTrialPriceRelay: BehaviorRelay<String> = .init(value: "$6.99")
    var subPriceRelay: BehaviorRelay<String> = .init(value: "$6.99")
    
    private lazy var coverButton: UIButton = UIButton()
    private lazy var mainTitleLabel: UILabel =
        .semiBoldTitleLabel(withText: "", ofSize: 14.0)
        .textAlignment(.center)
    private lazy var subTitleLabel: UILabel =
        .regularTitleLabel(withText: TextConst.subTitleText, ofSize: 12.0)
        .textAlignment(.center)
    private lazy var arrowView: UIView = .simpleView(color: .black)
    private lazy var arrowImageView: UIImageView = UIImageView(image: .arrowIcon)
    
    var tap: Observable<Void> {
        coverButton.rx.tap.asObservable()
    }
    
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
        Observable
            .combineLatest(isTrialRelay, subTrialPriceRelay, subPriceRelay)
            .map { isTrial, trialPrice, price in
                isTrial
                    ? TextConst.getTrialSubTitleText(with: trialPrice)
                    : TextConst.getSubTitleText(with: price)
            }
            .bind(to: mainTitleLabel.rx.text)
            .disposed(by: bag)
        
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
private extension PaywallButtonView {
    
    func commonInit() {
        backgroundColor = .appButton
        addSubview(coverButton)
        coverButton.layer.zPosition = .greatestFiniteMagnitude
        addSubview(mainTitleLabel)
        addSubview(subTitleLabel)
        addSubview(arrowView)
        arrowView.addSubview(arrowImageView)
    }
    
    func setupSnapkitConstraints() {
        coverButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.top.equalToSuperview().inset(16.0)
        }
        
        snp.makeConstraints { make in
            make.height.equalTo(ButtonParams.buttonHeight)
        }
        radius = ButtonParams.buttonCornerRadius
        
        mainTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16.0)
            make.centerX.equalToSuperview()
        }
        subTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(mainTitleLabel.snp.bottom)
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


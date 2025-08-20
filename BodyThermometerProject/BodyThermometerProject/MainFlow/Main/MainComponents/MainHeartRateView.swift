//
//  HearRateView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 19.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class MainHeartRateView: UIView {
    
    private enum TextConst {
        static let titleText = "Heart rate"
        static let bmpText = "BMP"
    }
    
    private enum LayoutConst {
        static let height: CGFloat = 230.0
        static let circleViewSize: CGFloat = 48.0
        static let arrowViewSize: CGFloat = 48.0
        static let bmpViewSize: CGSize = .init(width: 81.0, height: 49.0)
    }
    
    private lazy var titleLabel: UILabel =
        .mediumTitleLabel(withText: TextConst.titleText, ofSize: 18.0)
    
    private lazy var mainIconImageView: UIImageView =
        UIImageView(image: UIImage.mainHeartRate)
        .contentMode(.scaleAspectFit)
    private lazy var hearImageView: UIImageView =
    UIImageView(image: UIImage.mainHeart)
    
    private lazy var heartCircleView: UIView =
    UIView().bgColor(.appButton)
    private lazy var heartIconImageView: UIImageView =
    UIImageView(image: .mainHeartIcon)
    
    private lazy var bmpView: UIView =
    UIView().bgColor(.appBlack)
    
    private lazy var userBMPLabel: UILabel =
        .mediumTitleLabel(withText: "--", ofSize: 24.0, color: .appWhite)
    
    private lazy var bmpLabel: UILabel =
        .regularTitleLabel(withText: TextConst.bmpText,
                           ofSize: 12.0,
                           color: .appWhite)
    
    private lazy var arrowView: UIView =
    UIView()
        .bgColor(.appBlack)
    private lazy var arrowImageView: UIImageView =
    UIImageView(image: .arrowIcon)
    
    private lazy var coverButton: UIButton = UIButton()
    
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

//MARK: Private
private extension MainHeartRateView {
    
    func commonInit() {
        self.backgroundColor = .appWhite
        self.radius = 24.0
        //add subs
        self.addSubview(titleLabel)
        self.addSubview(heartCircleView)
        heartCircleView.addSubview(heartIconImageView)
        self.addSubview(bmpView)
        bmpView.addSubview(bmpLabel)
        bmpView.addSubview(userBMPLabel)
        self.addSubview(mainIconImageView)
        self.addSubview(arrowView)
        arrowView.addSubview(arrowImageView)
        self.addSubview(hearImageView)
        self.addSubview(coverButton)
        coverButton.layer.zPosition = .greatestFiniteMagnitude
    }
    
    func setupSnapkitConstraints() {
        self.snp.makeConstraints { make in
            make.height.equalTo(LayoutConst.height)
        }
        heartCircleView.snp.makeConstraints { make in
            make.size.equalTo(LayoutConst.arrowViewSize)
            make.top.equalToSuperview().inset(16.0)
            make.left.equalToSuperview().inset(12.0)
        }
        heartCircleView.radius = LayoutConst.arrowViewSize / 2
        heartIconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(heartCircleView.snp.bottom).offset(8.0)
            make.centerX.equalToSuperview()
        }
        mainIconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
        }
        hearImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        bmpView.snp.makeConstraints { make in
            make.size.equalTo(LayoutConst.bmpViewSize)
            make.bottom.equalToSuperview().inset(10.0)
            make.left.equalToSuperview().inset(12.0)
        }
        bmpView.radius = LayoutConst.bmpViewSize.height / 2
        userBMPLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(16.0)
            
        }
        bmpLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(userBMPLabel.snp.right).offset(4.0)
        }
        arrowView.snp.makeConstraints { make in
            make.size.equalTo(LayoutConst.circleViewSize)
            make.bottom.equalToSuperview().inset(10.0)
            make.right.equalToSuperview().inset(12.0)
        }
        arrowView.radius = LayoutConst.circleViewSize / 2
        arrowImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        coverButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}


//
//  StatisticsDataView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 19.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class MainStatisticsDataView: UIView {
    
    private enum TextConst {
        static let titleText = "Statistics data"
    }
    
    private enum LayoutConst {
        static let height: CGFloat = 278.0
        static let circleViewSize: CGFloat = 48.0
        static let arrowViewSize: CGFloat = 48.0
    }
    
    private lazy var titleLabel: UILabel =
        .mediumTitleLabel(withText: TextConst.titleText, ofSize: 18.0)
    
    private lazy var mainIconImageView: UIImageView =
        UIImageView(image: UIImage.mainStatistics)
        .contentMode(.scaleAspectFit)
    
    private lazy var statCircleView: UIView =
    UIView().bgColor(.appButton)
    private lazy var statIconImageView: UIImageView =
    UIImageView(image: UIImage.mainStatisticsIcon)
    
    private lazy var arrowView: UIView =
    UIView()
        .bgColor(.appBlack)
    private lazy var arrowImageView: UIImageView =
    UIImageView(image: .arrowIcon)
    
    private lazy var coverButton: UIButton = UIButton()
    
    var tap: Observable<Void> {
        coverButton.rx.tap.asObservable()
    }
    
    private var bag = DisposeBag()
    
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
private extension MainStatisticsDataView {
    
    func commonInit() {
        self.backgroundColor = .appWhite
        self.radius = 24.0
        //add subs
        self.addSubview(titleLabel)
        self.addSubview(statCircleView)
        statCircleView.addSubview(statIconImageView)
        self.addSubview(mainIconImageView)
        self.addSubview(arrowView)
        arrowView.addSubview(arrowImageView)
        self.addSubview(coverButton)
        coverButton.layer.zPosition = .greatestFiniteMagnitude
    }
    
    func setupSnapkitConstraints() {
        statCircleView.snp.makeConstraints { make in
            make.size.equalTo(LayoutConst.arrowViewSize)
            make.top.equalToSuperview().inset(16.0)
            make.left.equalToSuperview().inset(12.0)
        }
        statCircleView.radius = LayoutConst.arrowViewSize / 2
        statIconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(statCircleView.snp.bottom).offset(8.0)
            make.centerX.equalToSuperview()
        }
        mainIconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(119.0)
            make.left.equalToSuperview().inset(12.0)
            make.bottom.equalToSuperview().inset(10.0)
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


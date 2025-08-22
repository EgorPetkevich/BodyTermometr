//
//  RegistrationGenderCellsView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 17.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class RegistrationGenderCellsView: UIView {
    
    private enum TextConst {
        static let female: String = "Female"
        static let male: String = "Male"
    }
    
    private enum LayoutConst {
        static let cellRadius: CGFloat = 16.0
        static let cellHeight: CGFloat = 128.0
    }
    
    private lazy var femaleLabel: UILabel =
        .mediumTitleLabel(withText: TextConst.female,
                          ofSize: 18.0,
                          color: .appWhite)
    private lazy var maleLabel: UILabel =
        .mediumTitleLabel(withText: TextConst.male,
                          ofSize: 18.0,
                          color: .appBlack)
    
    private lazy var femaleImageView: UIImageView =
    UIImageView(image: .regFemale)
    private lazy var maleImageView: UIImageView =
    UIImageView(image: .regMale)
    
    private lazy var femaleView: UIView =
    UIView()
        .bgColor(.black)
    private lazy var maleView: UIView =
    UIView()
        .bgColor(.white)
    
    private lazy var femaleCoverButton: UIButton = UIButton()
    private lazy var maleCoverButton: UIButton = UIButton()
    
    var selectedGenderSubject: BehaviorSubject<Gender> = .init(value: .female)
    
    var femailSelected: Observable<Void> {
        femaleCoverButton.rx.tap.asObservable()
    }
    var maleSelected: Observable<Void> {
        maleCoverButton.rx.tap.asObservable()
    }
    
    private var bag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setuSnapKitConstraints()
        setupBorders()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        selectedGenderSubject
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] gender in
                self?.updateSelection(gender)
            })
            .disposed(by: bag)
        
        femaleCoverButton.rx.tap
            .map { Gender.female }
            .bind(to: selectedGenderSubject)
            .disposed(by: bag)

        maleCoverButton.rx.tap
            .map { Gender.male }
            .bind(to: selectedGenderSubject)
            .disposed(by: bag)
    }
    
}

//MARK: - Private
extension RegistrationGenderCellsView {
    
    func commonInit() {
        self.addSubview(femaleView)
        femaleView.addSubview(femaleImageView)
        femaleView.addSubview(femaleLabel)
        femaleView.addSubview(femaleCoverButton)
        self.addSubview(maleView)
        maleView.addSubview(maleImageView)
        maleView.addSubview(maleLabel)
        maleView.addSubview(maleCoverButton)
        
        femaleCoverButton.layer.zPosition = .greatestFiniteMagnitude
        maleCoverButton.layer.zPosition = .greatestFiniteMagnitude
    }
    
    func setuSnapKitConstraints() {
        self.snp.makeConstraints { make in
            make.height.equalTo(LayoutConst.cellHeight)
        }
        femaleView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.height.equalToSuperview()
            make.right.equalTo(self.snp.centerX).inset(4.0)
        }

        femaleImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(8.0)
        }
        femaleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(8.0)
        }
        femaleCoverButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        maleView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.height.equalToSuperview()
            make.left.equalTo(self.snp.centerX).offset(4.0)
        }
        maleImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(8.0)
        }
        maleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(8.0)
        }
        maleCoverButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setupBorders() {
        femaleView.layer.cornerRadius = LayoutConst.cellRadius
        maleView.layer.cornerRadius = LayoutConst.cellRadius
        femaleView.layer.masksToBounds = true
        maleView.layer.masksToBounds = true
    }
    
    private func updateSelection(_ gender: Gender) {
        setGenderView(
            view: femaleView,
            label: femaleLabel,
            isSelected: gender == .female
        )
        setGenderView(
            view: maleView,
            label: maleLabel,
            isSelected: gender == .male
        )
    }

    private func setGenderView(view: UIView, label: UILabel, isSelected: Bool) {
        view.backgroundColor = isSelected ? .appBlack : .appWhite
        label.textColor = isSelected ? .appWhite : .appBlack
    }
    
    
}

//
//  MeasureSiteView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 31.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

enum MeasuringSiteUnit: String {
    case oral = "Oral"
    case forehead = "Forehead"
    case other = "Other"
    
    static func getSite(title: String?) -> MeasuringSiteUnit {
        let key = title?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        switch key {
        case "oral": return .oral
        case "forehead": return .forehead
        case "other": return .other
        default: return .oral
        }
    }
}

final class MeasureSiteView: UIView {
    
    private let bag = DisposeBag()
    
    let selectedUnit = PublishRelay<MeasuringSiteUnit>()
    
    private lazy var titleLabel: UILabel =
        .mediumTitleLabel(withText: "Measure Site", ofSize: 18.0)
    
    private lazy var buttonsView: UIView =
    UIView()
        .bgColor(.appWhite.withAlphaComponent(0.6))
    
    private let oralButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(MeasuringSiteUnit.oral.rawValue, for: .normal)
        button.titleLabel?.font = UIFont.appRegularFont(ofSize: 12.0)
        button.layer.cornerRadius = 7
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.clear.cgColor
        button.clipsToBounds = true
        button.setTitleColor(.appBlack, for: .normal)
        button.backgroundColor = .clear
        return button
    }()
    
    private let foreheadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(MeasuringSiteUnit.forehead.rawValue, for: .normal)
        button.titleLabel?.font = UIFont.appRegularFont(ofSize: 12.0)
        button.layer.cornerRadius = 7
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.clear.cgColor
        button.clipsToBounds = true
        button.setTitleColor(.appGrey, for: .normal)
        button.backgroundColor = .clear
        return button
    }()
    
    private let otherButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(MeasuringSiteUnit.other.rawValue, for: .normal)
        button.titleLabel?.font = UIFont.appRegularFont(ofSize: 12.0)
        button.layer.cornerRadius = 7
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.clear.cgColor
        button.clipsToBounds = true
        button.setTitleColor(.appGrey, for: .normal)
        button.backgroundColor = .clear
        return button
    }()
    
    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [oralButton, foreheadButton, otherButton]
        )
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 0
        return stack
    }()
    
    private lazy var firstSeparatorView: UIView =
    UIView().bgColor(.appGrey.withAlphaComponent(0.3))
    private lazy var secondSeparatorView: UIView =
    UIView().bgColor(.appGrey.withAlphaComponent(0.3))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        bind()
    }
    
    private func bind() {
        oralButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.selectedUnit.accept(.oral)
                self.updateSelection(.oral)
            })
            .disposed(by: bag)
        
        foreheadButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.selectedUnit.accept(.forehead)
                self.updateSelection(.forehead)
            })
            .disposed(by: bag)
        otherButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.selectedUnit.accept(.other)
                self.updateSelection(.other)
            })
            .disposed(by: bag)
        
        selectedUnit
            .subscribe(onNext: { [weak self] unit in
                self?.updateSelection(unit)
            })
            .disposed(by: bag)
    }
    
}

//MARK: - Private
private extension MeasureSiteView {
    
    private func setupUI() {
        backgroundColor = .clear
        addSubview(buttonsView)
        addSubview(titleLabel)
        buttonsView.addSubview(buttonsStack)
        buttonsView.addSubview(firstSeparatorView)
        buttonsView.addSubview(secondSeparatorView)
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.left.equalToSuperview()
        }
        buttonsView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 189.0, height: 28))
            make.centerY.right.equalToSuperview()
        }
        buttonsView.radius = 9.0
        buttonsStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(2.0)
        }
        firstSeparatorView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 1.0, height: 12.0))
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(58.0)
        }
        firstSeparatorView.radius = 0.5
        secondSeparatorView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 1.0, height: 12.0))
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(58.0)
        }
        secondSeparatorView.radius = 0.5
        
//        updateSelection(selectedUnit.value)
    }
 
    private func updateSelection(_ unit: MeasuringSiteUnit) {
        let buttons: [MeasuringSiteUnit: UIButton] = [
            .oral: oralButton,
            .forehead: foreheadButton,
            .other: otherButton
        ]
        
        buttons.values.forEach { style(button: $0, isSelected: false) }
        
        if let selected = buttons[unit] {
            style(button: selected, isSelected: true)
        }
    
        updateSeparators(for: unit)
    }

    private func style(button: UIButton, isSelected: Bool) {
        if isSelected {
            button.layer.borderColor = UIColor.appButton.cgColor
            button.setTitleColor(.appBlack, for: .normal)
            button.backgroundColor = .appWhite
        } else {
            button.layer.borderColor = UIColor.clear.cgColor
            button.setTitleColor(.appGrey, for: .normal)
            button.backgroundColor = .appWhite.withAlphaComponent(0.6)
        }
    }

    private func updateSeparators(for unit: MeasuringSiteUnit) {
        switch unit {
        case .oral:
            firstSeparatorView.isHidden = true
            secondSeparatorView.isHidden = false
        case .forehead:
            firstSeparatorView.isHidden = true
            secondSeparatorView.isHidden = true
        case .other:
            firstSeparatorView.isHidden = false
            secondSeparatorView.isHidden = true
        }
    }
    
}


//
//  TempreratureSwitch.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 30.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class TemperatureSwitchView: UIView {
    
    private let bag = DisposeBag()
    
    let selectedUnit = BehaviorRelay<TempUnit>(value: .c)
    
    private let celsiusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(TempUnit.c.title, for: .normal)
        button.titleLabel?.font = UIFont.appRegularFont(ofSize: 15.0)
        button.layer.cornerRadius = 7
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.clear.cgColor
        button.clipsToBounds = true
        button.setTitleColor(.appBlack, for: .normal)
        button.backgroundColor = .clear
        return button
    }()
    
    private let fahrenheitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(TempUnit.f.title, for: .normal)
        button.titleLabel?.font = UIFont.appRegularFont(ofSize: 15.0)
        button.layer.cornerRadius = 7
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.clear.cgColor
        button.clipsToBounds = true
        button.setTitleColor(.appGrey, for: .normal)
        button.backgroundColor = .clear
        return button
    }()
    
    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [celsiusButton, fahrenheitButton])
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 0
        return stack
    }()
    
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
        celsiusButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.selectedUnit.accept(.c)
                self.updateSelection(.c)
            })
            .disposed(by: bag)
        
        fahrenheitButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.selectedUnit.accept(.f)
                self.updateSelection(.f)
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
private extension TemperatureSwitchView {
    
    private func setupUI() {
        addSubview(buttonsStack)
        buttonsStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4.0)
        }
        layer.cornerRadius = 12
        layer.masksToBounds = true
        backgroundColor = UIColor.white
        updateSelection(selectedUnit.value)
    }
 
    private func updateSelection(_ unit: TempUnit) {
        switch unit {
        case .c:
            celsiusButton.layer.borderColor = UIColor.appButton.cgColor
            celsiusButton.setTitleColor(.black, for: .normal)
            fahrenheitButton.layer.borderColor = UIColor.clear.cgColor
            fahrenheitButton.setTitleColor(.appGrey, for: .normal)
        case .f:
            fahrenheitButton.layer.borderColor = UIColor.appButton.cgColor
            fahrenheitButton.setTitleColor(.appBlack, for: .normal)
            celsiusButton.layer.borderColor = UIColor.clear.cgColor
            celsiusButton.setTitleColor(.appGrey, for: .normal)
        }
    }
    
}

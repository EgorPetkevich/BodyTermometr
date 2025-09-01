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
    
    let selectedUnit = BehaviorRelay<TemperatureUnit>(value: .celsius)
    
    private let celsiusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(TemperatureUnit.celsius.rawValue, for: .normal)
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
        button.setTitle(TemperatureUnit.fahrenheit.rawValue, for: .normal)
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
                self.selectedUnit.accept(.celsius)
                self.updateSelection(.celsius)
            })
            .disposed(by: bag)
        
        fahrenheitButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.selectedUnit.accept(.fahrenheit)
                self.updateSelection(.fahrenheit)
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
 
    private func updateSelection(_ unit: TemperatureUnit) {
        switch unit {
        case .celsius:
            celsiusButton.layer.borderColor = UIColor.appButton.cgColor
            celsiusButton.setTitleColor(.black, for: .normal)
            fahrenheitButton.layer.borderColor = UIColor.clear.cgColor
            fahrenheitButton.setTitleColor(.appGrey, for: .normal)
        case .fahrenheit:
            fahrenheitButton.layer.borderColor = UIColor.appButton.cgColor
            fahrenheitButton.setTitleColor(.appBlack, for: .normal)
            celsiusButton.layer.borderColor = UIColor.clear.cgColor
            celsiusButton.setTitleColor(.appGrey, for: .normal)
        }
    }
    
}

//
//  TempUnitControlView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 2.09.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

enum TempUnit {
    case c, f
    
    var title: String {
        switch self {
        case .c:
            "Celsius,ºC"
        case .f:
            "Fahrenheit, F"
        }
    }
    
    static func getUnit(_ unit: String) -> TempUnit {
        let normalized = unit
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        
        switch normalized {
        case "c", "celsius":
            return .c
        case "f", "fahrenheit":
            return .f
        default:
            return .c
        }
    }
}

final class TempUnitControlView: UIView {
    
    let selectedUnit = BehaviorRelay<TempUnit>(value: .c)

    private let cButton = UIButton(type: .system)
    private let fButton = UIButton(type: .system)
    private let container = UIView().bgColor(.appWhite)
    private let bag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupButtons()
        bind()
    }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }
    
    private func bind() {
        cButton.rx.tap
            .subscribe(onNext: { [weak self] in self?.selectedUnit.accept(.c) })
            .disposed(by: bag)
        fButton.rx.tap
            .subscribe(onNext: { [weak self] in self?.selectedUnit.accept(.f) })
            .disposed(by: bag)

        selectedUnit
            .subscribe(onNext: { [weak self] unit in
                guard let self else { return }
                self.style(active: unit == .c ? cButton : fButton,
                           inactive: unit == .c ? fButton : cButton)
            })
            .disposed(by: bag)
    }
    
    func setSelected(_ unit: TempUnit) {
        selectedUnit.accept(unit)
    }

    private func setup() {
        self.backgroundColor = .appLightGrey
        self.radius = 9.0
        addSubview(container)
        container.snp.makeConstraints { $0.edges.equalToSuperview().inset(2.0) }
        container.radius = 9.0
    }
    
    private func setupButtons() {
        cButton.snp.makeConstraints { make in
            make.width.equalTo(49.0)
        }
        fButton.snp.makeConstraints { make in
            make.width.equalTo(24.0)
        }
        
        [cButton, fButton].forEach { b in
            b.titleLabel?.font = .appRegularFont(ofSize: 12)
            b.setTitleColor(UIColor.appBlack, for: .normal)
            b.backgroundColor = .clear
            b.layer.cornerRadius = 7
            b.layer.borderWidth = 1
            b.layer.borderColor = UIColor.clear.cgColor
            b.clipsToBounds = true
        }
        cButton.setTitle("ºC", for: .normal)
        fButton.setTitle("F", for: .normal)

        let stack = UIStackView(arrangedSubviews: [cButton, fButton])
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 0
        container.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    private func style(active: UIButton, inactive: UIButton) {
        active.backgroundColor = UIColor.appWhite
        active.layer.borderColor = UIColor.appButton.cgColor
        inactive.backgroundColor = .clear
        inactive.layer.borderColor = UIColor.clear.cgColor
    }
}

extension Reactive where Base: TempUnitControlView {
    var selected: Binder<TempUnit> {
        Binder(base) { view, unit in
            view.setSelected(unit)
        }
    }
    var state: ControlEvent<TempUnit> {
        ControlEvent(events: base.selectedUnit.asObservable().distinctUntilChanged())
    }
}

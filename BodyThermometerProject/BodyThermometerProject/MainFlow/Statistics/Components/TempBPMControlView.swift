//
//  TempBPMControlView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 2.09.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

enum StatMode {
    case temperature
    case heartRate
}

final class TempBPMControlView: UIView {
    
    private let temperatureButton: UIButton =
    UIButton(type: .system)
        .setTitle("Body temperature")
        .setFont(.appMediumFont(ofSize: 18.0))
    
    private let heartRateButton: UIButton =
    UIButton(type: .system)
        .setTitle("Heart rate")
        .setFont(.appMediumFont(ofSize: 18.0))
    
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillProportionally
        sv.alignment = .center
        sv.spacing = 16
        return sv
    }()
    
    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private let disposeBag = DisposeBag()
    
    private(set) var selectedRelay = BehaviorRelay<StatMode>(value: .temperature)
    
    private var underlineNeedsUpdate = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupBindings()
        applyColors(for: selectedRelay.value)
        underlineNeedsUpdate = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupBindings()
        applyColors(for: selectedRelay.value)
        underlineNeedsUpdate = true
    }
    
    private func setupViews() {
        addSubview(stackView)
        stackView.addArrangedSubview(temperatureButton)
        stackView.addArrangedSubview(heartRateButton)
        addSubview(underlineView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Safe initial constraints for underline to avoid width==0 conflicts before layout
        underlineView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.width.equalTo(0) // will be updated on first layout pass
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupBindings() {
        temperatureButton.rx.tap
            .map { StatMode.temperature }
            .bind(to: selectedRelay)
            .disposed(by: disposeBag)
        
        heartRateButton.rx.tap
            .map { StatMode.heartRate }
            .bind(to: selectedRelay)
            .disposed(by: disposeBag)
        
        selectedRelay
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] mode in
                self?.applyColors(for: mode)
                self?.underlineNeedsUpdate = true
                self?.setNeedsLayout()
            })
            .disposed(by: disposeBag)
    }
    
    private func applyColors(for mode: StatMode) {
        let selectedColor = UIColor.appBlack
        let unselectedColor = UIColor.appBlack.withAlphaComponent(0.3)
        switch mode {
        case .temperature:
            temperatureButton.setTitleColor(selectedColor, for: .normal)
            heartRateButton.setTitleColor(unselectedColor, for: .normal)
        case .heartRate:
            heartRateButton.setTitleColor(selectedColor, for: .normal)
            temperatureButton.setTitleColor(unselectedColor, for: .normal)
        }
    }
    
    private func updateUI(for mode: StatMode) {
        applyColors(for: mode)
        underlineNeedsUpdate = true
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard underlineNeedsUpdate, bounds.width > 0, bounds.height > 0 else { return }
        underlineNeedsUpdate = false

        let targetButton = (selectedRelay.value == .temperature) ? temperatureButton : heartRateButton
        guard let titleLabel = targetButton.titleLabel else { return }

        // Ensure the stack has laid out its subviews before reading frames
        targetButton.layoutIfNeeded()
        titleLabel.layoutIfNeeded()

        underlineView.snp.remakeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.width.equalTo(titleLabel.snp.width)
            make.centerX.equalTo(titleLabel.snp.centerX)
        }

        // Animate only if we are already in a window (subsequent updates)
        if window != nil {
            UIView.animate(withDuration: 0.20) {
                self.layoutIfNeeded()
            }
        } else {
            self.layoutIfNeeded()
        }
    }
    
    var selected: Observable<StatMode> {
        selectedRelay.asObservable().distinctUntilChanged()
    }
    
    func setSelected(_ mode: StatMode) {
        selectedRelay.accept(mode)
    }
}

extension Reactive where Base: TempBPMControlView {
    var selected: Binder<StatMode> {
        Binder(base) { view, mode in
            view.setSelected(mode)
        }
    }
    var mode: ControlEvent<StatMode> {
        ControlEvent(events: base.selectedRelay.asObservable().distinctUntilChanged())
    }
}

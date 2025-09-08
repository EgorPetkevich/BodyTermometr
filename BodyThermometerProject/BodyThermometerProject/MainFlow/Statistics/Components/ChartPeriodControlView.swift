//
//  ChartPeriodControlView.swift.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 2.09.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit


final class ChartPeriodControlView: UIView {
    
    let selectedPeriod = BehaviorRelay<Period>(value: .day)
    private let bag = DisposeBag()
    
    private lazy var buttonsView: UIView = UIView().bgColor(.appWhite.withAlphaComponent(0.6))

    private let dayButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Day", for: .normal)
        button.titleLabel?.font = UIFont.appRegularFont(ofSize: 12.0)
        button.layer.cornerRadius = 7
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.clear.cgColor
        button.clipsToBounds = true
        button.setTitleColor(.appBlack, for: .normal)
        button.backgroundColor = .clear
        return button
    }()

    private let weekButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Week", for: .normal)
        button.titleLabel?.font = UIFont.appRegularFont(ofSize: 12.0)
        button.layer.cornerRadius = 7
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.clear.cgColor
        button.clipsToBounds = true
        button.setTitleColor(.appGrey, for: .normal)
        button.backgroundColor = .clear
        return button
    }()

    private let monthButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Month", for: .normal)
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
        let stack = UIStackView(arrangedSubviews: [dayButton, weekButton, monthButton])
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
        dayButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.selectedPeriod.accept(.day)
            })
            .disposed(by: bag)

        weekButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.selectedPeriod.accept(.week)
            })
            .disposed(by: bag)

        monthButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.selectedPeriod.accept(.month)
            })
            .disposed(by: bag)

        selectedPeriod
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] period in
                self?.updateSelection(period)
            })
            .disposed(by: bag)
    }
    
    private func setupUI() {
        backgroundColor = .appLightGrey
        addSubview(buttonsView)
        buttonsView.addSubview(buttonsStack)
        buttonsView.addSubview(firstSeparatorView)
        buttonsView.addSubview(secondSeparatorView)

        self.snp.makeConstraints { make in
            make.height.equalTo(28.0)
        }

        buttonsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        buttonsView.radius = 9.0

        buttonsStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(2.0)
        }

        firstSeparatorView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 1.0, height: 12.0))
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(108.0)
        }
        firstSeparatorView.radius = 0.5

        secondSeparatorView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 1.0, height: 12.0))
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(108.0)
        }
        secondSeparatorView.radius = 0.5

        updateSelection(selectedPeriod.value)
    }
    
    func setSelected(_ period: Period) {
        if Thread.isMainThread {
            selectedPeriod.accept(period)
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.selectedPeriod.accept(period)
            }
        }
    }
    
    private func updateSelection(_ period: Period) {
        let buttons: [Period: UIButton] = [
            .day: dayButton,
            .week: weekButton,
            .month: monthButton
        ]

        buttons.values.forEach { style(button: $0, isSelected: false) }
        if let selected = buttons[period] { style(button: selected, isSelected: true) }
        updateSeparators(for: period)
    }

    private func style(button: UIButton, isSelected: Bool) {
        if isSelected {
            button.layer.borderColor = UIColor.appButton.cgColor
            button.setTitleColor(.appBlack, for: .normal)
            button.backgroundColor = .appWhite
        } else {
            button.layer.borderColor = UIColor.clear.cgColor
            button.setTitleColor(.appBlack, for: .normal)
            button.backgroundColor = .appLightGrey
        }
    }

    private func updateSeparators(for period: Period) {
        switch period {
        case .day:
            firstSeparatorView.isHidden = true
            secondSeparatorView.isHidden = false
        case .week:
            firstSeparatorView.isHidden = true
            secondSeparatorView.isHidden = true
        case .month:
            firstSeparatorView.isHidden = false
            secondSeparatorView.isHidden = true
        }
    }
}

extension Reactive where Base: ChartPeriodControlView {
    var selected: Binder<Period> {
        Binder(base) { view, mode in
            view.setSelected(mode)
        }
    }
    var period: ControlEvent<Period> {
        ControlEvent(events: base.selectedPeriod.asObservable().distinctUntilChanged())
    }
}

//
//  HistoryGuideControlView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 3.09.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

enum TableSegment {
    case history
    case guide
}

final class HistoryGuideControlView: UIView {
    
    let selectedSegmentRelay = BehaviorRelay<TableSegment>(value: .history)
    private let bag = DisposeBag()
    
    private lazy var buttonsView: UIView = UIView().bgColor(.appWhite.withAlphaComponent(0.6))
    
    private let historyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("History", for: .normal)
        button.titleLabel?.font = UIFont.appRegularFont(ofSize: 12.0)
        button.layer.cornerRadius = 7
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.clear.cgColor
        button.clipsToBounds = true
        button.setTitleColor(.appGrey, for: .normal)
        button.backgroundColor = .appWhite
        return button
    }()
    
    private let guideButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Interpretation Guide", for: .normal)
        button.titleLabel?.font = UIFont.appRegularFont(ofSize: 12.0)
        button.layer.cornerRadius = 7
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.clear.cgColor
        button.clipsToBounds = true
        button.setTitleColor(.appGrey, for: .normal)
        button.backgroundColor = .appWhite
        return button
    }()
    
    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [historyButton, guideButton])
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
        historyButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.selectedSegmentRelay.accept(.history)
                self.updateSelection(.history)
            })
            .disposed(by: bag)
        
        guideButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.selectedSegmentRelay.accept(.guide)
                self.updateSelection(.guide)
            })
            .disposed(by: bag)
        
        selectedSegmentRelay
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] segment in
                self?.updateSelection(segment)
            })
            .disposed(by: bag)
    }
    
    private func setupUI() {
        self.radius = 9.0
        backgroundColor = .appLightGrey
        addSubview(buttonsView)
        buttonsView.radius = 9.0
        buttonsView.addSubview(buttonsStack)
        
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
        
        updateSelection(selectedSegmentRelay.value)
    }
    
    func setSelected(_ segment: TableSegment) {
        selectedSegmentRelay.accept(segment)
    }
    
    private func updateSelection(_ segment: TableSegment) {
        switch segment {
        case .history:
            historyButton.backgroundColor = .appBlack
            historyButton.setTitleColor(.appWhite, for: .normal)
            guideButton.backgroundColor = .appWhite
            guideButton.setTitleColor(.appGrey, for: .normal)
        case .guide:
            guideButton.backgroundColor = .appBlack
            guideButton.setTitleColor(.appWhite, for: .normal)
            historyButton.backgroundColor = .appWhite
            historyButton.setTitleColor(.appGrey, for: .normal)
        }
    }
}

extension Reactive where Base: HistoryGuideControlView {
    var selected: Binder<TableSegment> {
        Binder(base) { view, mode in
            view.setSelected(mode)
        }
    }
    var segment: ControlEvent<TableSegment> {
        ControlEvent(
            events:
                base.selectedSegmentRelay
                .asObservable()
                .distinctUntilChanged()
        )
    }
}

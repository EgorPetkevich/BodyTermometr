//
//  TempConditionTypeView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 30.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class TempConditionTypeView: UIView {
    
    private enum TextConst {
        static let bodyTempText: String = "Body Temperature"
        static let feverTypeText: String = "Fever Type"
    }
    
    private enum LayoutConst {
        static let height: CGFloat = 80.0
        static let typeViewHeight: CGFloat = 25.0
    }
    
    var temperatureSubject = BehaviorSubject<Double?>(value: nil)
    var unitSubject = BehaviorSubject<TemperatureUnit?>(value: nil)
    
    private lazy var bodyTempLabel: UILabel =
        .regularTitleLabel(withText: TextConst.bodyTempText, ofSize: 15.0)
    
    private lazy var feverTypeLabel: UILabel =
        .regularTitleLabel(withText: TextConst.feverTypeText, ofSize: 15.0)
    
    private lazy var tempLabel: UILabel =
        .mediumTitleLabel(withText: "", ofSize: 18.0)
    
    private lazy var typeView: UIView = UIView()
    private lazy var typeLabel: UILabel =
        .semiBoldTitleLabel(withText: "", ofSize: 14.0, color: .white)
    
    private var bag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupSnapKitConstrains()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        let latest = Observable
            .combineLatest(
                temperatureSubject.compactMap { $0 },
                unitSubject.compactMap { $0 }
            )
            .share(replay: 1)

        latest
            .map { temp, unit -> String in
                let t = String(format: "%.1f", temp)
                    .replacingOccurrences(of: ".", with: ",")
                switch unit {
                case .celsius:    return "\(t)ºC"
                case .fahrenheit: return "\(t)F"
                }
            }
            .bind(to: tempLabel.rx.text)
            .disposed(by: bag)

        latest
            .map { temp, unit -> TemperatureStatus in
                return TemperatureStatus(value: temp, unit: unit)
            }
            .subscribe(onNext: { [weak self] status in
                self?.typeLabel.text = status.title
                self?.typeView.backgroundColor = status.color
            })
            .disposed(by: bag)
    }
    
}

//MARK: - Private
private extension TempConditionTypeView {
    
    func commonInit() {
        self.backgroundColor = .appWhite
        self.addSubview(bodyTempLabel)
        self.addSubview(tempLabel)
        self.addSubview(feverTypeLabel)
        self.addSubview(typeView)
        typeView.addSubview(typeLabel)
    }
    
    func setupSnapKitConstrains() {
        self.snp.makeConstraints { make in
            make.height.equalTo(LayoutConst.height)
        }
        self.radius = 16.0
        bodyTempLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16.0)
            make.leading.equalToSuperview().inset(16.0)
        }
        tempLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16.0)
            make.bottom.equalToSuperview().inset(16.0)
        }
        feverTypeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16.0)
            make.leading.equalTo(bodyTempLabel.snp.trailing).offset(32.0)
        }
        typeView.snp.makeConstraints { make in
            make.height.equalTo(LayoutConst.typeViewHeight)
            make.bottom.equalToSuperview().inset(15.0)
            make.leading.equalTo(feverTypeLabel.snp.leading)
        }
        typeView.radius = LayoutConst.typeViewHeight / 2
        typeLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(8.0)
        }
    }
    
}

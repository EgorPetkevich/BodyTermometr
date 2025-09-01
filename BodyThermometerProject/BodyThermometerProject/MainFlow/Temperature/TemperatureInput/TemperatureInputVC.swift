//
//  TemperatureInputVC.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 30.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol TemperatureInputViewModelProtocol {
    //In
    var keyBoardFrame: Observable<CGRect> { get }
    // Out
    var crossButtonTapped: PublishRelay<Void> { get }
    var continuButtonTapped: PublishRelay<Void> { get }
    var temperatureSubject: BehaviorSubject<Double?> { get }
    var temperatureUnitSubject: BehaviorSubject<TemperatureUnit?> { get }
}

final class TemperatureInputVC: UIViewController {
    
    private enum TextConst {
        static let titleText: String = "Add Temperature"
    }
    
    private enum LayoutConst {
        static let crossButtonSize: CGFloat = 48.0
        static let tempSwitchSize: CGSize = CGSize(width: 233.0, height: 32.0)
    }
    
    private var contButtonButtomConstarint: Constraint?
    
    private lazy var titleLabel: UILabel =
        .mediumTitleLabel(withText: TextConst.titleText, ofSize: 24.0)

    private lazy var crossButton: UIButton =
    UIButton(type: .system)
        .setImage(.crossIconBlack)
        .setBgColor(.appWhite)
        .setTintColor(.appBlack)
    
    private lazy var temperatureSwitchView: TemperatureSwitchView =
    TemperatureSwitchView()
   
    private lazy var temperatureInputView: TemperatureInputView =
    TemperatureInputView()
    
    private lazy var continueButtonView: ContinueButtonView =
    ContinueButtonView()
    
    private var viewModel: TemperatureInputViewModelProtocol
    
    private let bag = DisposeBag()
    
    init(viewModel: TemperatureInputViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBg
        commonInit()
        setupSnapKitConstraints()
        bind()
    }
    
    private func bind() {
        temperatureInputView.unit = temperatureSwitchView.selectedUnit.value

        temperatureSwitchView.selectedUnit
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] unit in
                self?.temperatureInputView.unit = unit
            })
            .disposed(by: bag)
        
        temperatureSwitchView
            .selectedUnit
            .distinctUntilChanged()
            .bind(to: viewModel.temperatureUnitSubject)
            .disposed(by: bag)
        
        crossButton.rx.tap
            .bind(to: viewModel.crossButtonTapped)
            .disposed(by: bag)
        
        continueButtonView.tap
            .bind(to: viewModel.continuButtonTapped)
            .disposed(by: bag)
        
        temperatureInputView.temperature
            .bind(to: viewModel.temperatureSubject)
            .disposed(by: bag)
        
        viewModel.keyBoardFrame
            .map { $0.height }
            .map { height -> CGFloat in
                height > 0 ? 24 + height : 47
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] inset in
                guard let self else { return }
                self.contButtonButtomConstarint?.update(inset: inset)

                UIView.animate(withDuration: 0.25) {
                    self.view.layoutIfNeeded()
                }
            })
            .disposed(by: bag)
    }
    
}

private extension TemperatureInputVC {
    
    func commonInit() {
        view.addSubview(titleLabel)
        view.addSubview(crossButton)
        view.addSubview(temperatureSwitchView)
        view.addSubview(temperatureInputView)
        view.addSubview(continueButtonView)
    }
    
    func setupSnapKitConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(71.0)
        }
        crossButton.snp.makeConstraints { make in
            make.size.equalTo(LayoutConst.crossButtonSize)
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.left.equalToSuperview().inset(16.0)
        }
        crossButton.radius = LayoutConst.crossButtonSize / 2
        temperatureSwitchView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(LayoutConst.tempSwitchSize)
            make.top.equalTo(titleLabel.snp.bottom).offset(72.0)
        }
        temperatureInputView.snp.makeConstraints { make in
            make.top.equalTo(temperatureSwitchView.snp.bottom).offset(64.0)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(56.0)
        }
        continueButtonView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16.0)
            contButtonButtomConstarint =
            make.bottom.equalToSuperview().inset(47.0).constraint
        }
    }
    
}

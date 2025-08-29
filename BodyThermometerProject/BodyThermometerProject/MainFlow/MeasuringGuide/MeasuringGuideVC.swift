//
//  MeasuringGuideVC.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 26.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol MeasuringGuideViewModelProtocol {
    // Out
    var checkBoxState: Observable<Bool> { get }
    // In
    var checkBoxTapped: PublishSubject<Void> { get }
    var clouseButtonTapped: PublishSubject<Void> { get }
}

final class MeasuringGuideVC: UIViewController {
    
    private enum TextConst {
        static let clouseButtonText: String = "Clouse"
        static let guideText: String = "1. The circle above should appear bright red from \nthe light reflecting off your skin. \n2. Try to cover the whole lens and hold your phone \ncomfortably."
        static let dontShowAgainButtonText: String = " Don't show again"
    }
    
    private lazy var clouseButton: UIButton =
    UIButton(type: .system)
        .setTitle(TextConst.clouseButtonText)
        .setFont(.appRegularFont(ofSize: 12.0))
        .setTintColor(.appGrey)
    
    private lazy var guideLabel: UILabel =
        .regularTitleLabel(withText: TextConst.guideText, ofSize: 15.0)
        .textAlignment(.left)
        .numOfLines(4)
    
    private lazy var dontShowAgainButton: UIButton =
    UIButton(type: .system)
        .setTintColor(.appBlack)
        .setTitle(TextConst.dontShowAgainButtonText)
    
    private lazy var checkBoxImageView: UIImageView =
    UIImageView(image: .checkboxIcon)
    
    
    private lazy var phoneImageView: UIImageView =
    UIImageView(image: .measuringIphone16)
    
    private var viewModel: MeasuringGuideViewModelProtocol
    
    private var bag = DisposeBag()
    
    init(viewModel: MeasuringGuideViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        commonInit()
        setupSnapKitConstraints()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBg
        view.layer.cornerRadius = 32
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private func bind() {
        clouseButton.rx.tap
            .bind(to: viewModel.clouseButtonTapped)
            .disposed(by: bag)
        dontShowAgainButton.rx.tap
            .bind(to: viewModel.checkBoxTapped)
            .disposed(by: bag)
        
        viewModel.checkBoxState
            .subscribe(onNext: { [weak self] state in
                guard let self else { return }
                checkBoxImageView.image =
                state ? .checkboxFillIcon : .checkboxIcon
            })
            .disposed(by: bag)
    }
    
}

//MARK: - Private
private extension MeasuringGuideVC {
    
    func commonInit() {
        view.addSubview(clouseButton)
        view.addSubview(guideLabel)
        view.addSubview(dontShowAgainButton)
        view.addSubview(checkBoxImageView)
        view.addSubview(phoneImageView)
    }
    
    func setupSnapKitConstraints() {
        clouseButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16.0)
            make.top.equalToSuperview().inset(24.0)
        }
        guideLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16.0)
            make.top.equalToSuperview().inset(62.0)
        }
        dontShowAgainButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(guideLabel.snp.bottom).offset(24.0)
            make.height.equalTo(30.0)
            make.width.equalTo(142.0)
        }
        checkBoxImageView.snp.makeConstraints { make in
            make.centerY.equalTo(dontShowAgainButton.snp.centerY)
            make.right.equalTo(dontShowAgainButton.snp.left).offset(8.0)
        }
        phoneImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
}

//
//  PaywallRevVC.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 15.08.25.
//


import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol PaywallRevViewModelProtocol {
    //Out
    var showCrossButton: Observable<Void> { get }
    //In
    var crossTapped: PublishSubject<Void> { get }
    var viewDidLoad: PublishSubject<Void> { get }
    var didSelectPrivacy: PublishSubject<Void> { get }
    var didSelectRestore: PublishSubject<Void> { get }
    var didSelectTerms: PublishSubject<Void> { get }
}

final class PaywallRevVC: UIViewController {
    
    private enum TextConst {
        static let headerTitleText: String = "Full Access \n To All Features"
        static let underButtonText: String = "by continuing you agree to:"
        static let buttonText: String = "Auto renewable. Cancel anytime"
        static let privacyButtonText: String = "Privacy"
        static let restoreButtonText: String = "Restore"
        static let termsButtonText: String = "Terms"
        
        static func buttonSubText(with price: String) -> String {
            "Subscribe for \(price)/week."
        }
        static func buttonSubTrialText(with price: String) -> String {
            "Try 3-Day Trial, then \(price)/week."
        }
    }
    
    private lazy var headerTitleLabel: UILabel =
        .semiBoldTitleLabel(withText: TextConst.headerTitleText,
                            ofSize: 42.0)
        .textAlignment(.center)
        .numOfLines(2)
    
    private lazy var mainPaywallImageView: UIImageView =
    UIImageView(image: .paywallMain)
        .contentMode(.scaleAspectFill)
    
    private lazy var underButtonLabel: UILabel =
        .regularTitleLabel(withText: TextConst.underButtonText,
                           ofSize: 12.0,
                           color: .appBlack.withAlphaComponent(0.6))
    
    private var enableTrialView: EnableTrialView = EnableTrialView()
    private var paywallButtonView: PaywallButtonView = PaywallButtonView()
    
    private var crossButton: UIButton = .crossButton()

    private var privacyButton: UIButton =
        .footerActionButton(title: TextConst.privacyButtonText)
    private var restoreButton: UIButton =
        .footerActionButton(title: TextConst.restoreButtonText)
    private var termsButton: UIButton =
        .footerActionButton(title: TextConst.termsButtonText)
    
    
    private var viewModel: PaywallRevViewModelProtocol
    private var bag = DisposeBag()
    
    init(viewMode: PaywallRevViewModelProtocol) {
        self.viewModel = viewMode
        super.init(nibName: nil, bundle: nil)
        bind()
        commonInit()
        setupSnapkitConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad.onNext(())
    }
    
    private func bind() {
        viewModel.showCrossButton
            .observe(on: MainScheduler.instance)
            .map { false }
            .bind(to: crossButton.rx.isHidden)
            .disposed(by: bag)
        
        enableTrialView.isTrialRelay
            .bind(to: paywallButtonView.isTrialRelay)
            .disposed(by: bag)
        
        crossButton.rx.tap
            .bind(to: viewModel.crossTapped)
            .disposed(by: bag)
        
        privacyButton.rx.tap
            .bind(to: viewModel.didSelectPrivacy)
            .disposed(by: bag)
        
        restoreButton.rx.tap
            .bind(to: viewModel.didSelectRestore)
            .disposed(by: bag)
        
        termsButton.rx.tap
            .bind(to: viewModel.didSelectTerms)
            .disposed(by: bag)
    }
    
}

//MARK: - Private
private extension PaywallRevVC {
    
    func commonInit() {
        self.view.backgroundColor = .appBg
        self.crossButton.isHidden = true
        //add sub
        self.view.addSubview(headerTitleLabel)
        self.view.addSubview(mainPaywallImageView)
        self.view.addSubview(paywallButtonView)
        self.view.addSubview(underButtonLabel)
        self.view.addSubview(privacyButton)
        self.view.addSubview(restoreButton)
        self.view.addSubview(termsButton)
        self.view.addSubview(crossButton)
        self.view.addSubview(enableTrialView)
    }
    
    func setupSnapkitConstraints() {
        crossButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16.0)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(16.0)
        }
        headerTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(86.0)
        }
        mainPaywallImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(16.0)
            make.bottom.equalToSuperview().inset(213)
        }
        enableTrialView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16.0)
            make.bottom.equalTo(paywallButtonView.snp.top).inset(-24.0)
        }
        paywallButtonView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16.0)
            make.height.equalTo(64)
            make.bottom.equalToSuperview().inset(47.0)
        }
        underButtonLabel.snp.makeConstraints { make in
            make.top.equalTo(paywallButtonView.snp.bottom).offset(4.0)
            make.left.equalToSuperview().inset(43.0)
        }
        privacyButton.snp.makeConstraints { make in
            make.centerY.equalTo(underButtonLabel)
        }
        restoreButton.snp.makeConstraints { make in
            make.left.equalTo(privacyButton.snp.right).offset(10.0)
            make.centerY.equalTo(underButtonLabel)
        }
        termsButton.snp.makeConstraints { make in
            make.left.equalTo(restoreButton.snp.right).offset(10.0)
            make.centerY.equalTo(underButtonLabel)
            make.right.equalToSuperview().inset(43.0)
        }
    }
    
}


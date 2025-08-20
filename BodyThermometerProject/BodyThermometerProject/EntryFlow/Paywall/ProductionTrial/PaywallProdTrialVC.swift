//
//  PaywallProdTrialVC.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 14.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol PaywallProdTrialViewModelProtocol {
    //Out
    var showCrossButton: Observable<Void> { get }
    //In
    var crossTapped: PublishSubject<Void> { get }
    var viewDidLoad: PublishSubject<Void> { get }
    var didSelectPrivacy: PublishSubject<Void> { get }
    var didSelectRestore: PublishSubject<Void> { get }
    var didSelectTerms: PublishSubject<Void> { get }
}

final class PaywallProdTrialVC: UIViewController {
    
    private enum TextConst {
        static let headerTitleText: String = "Full Access \n To All Features"
        static let underHeaderText: String = "Enable 3-day free trial"
        static let underButtonText: String = "by continuing you agree to:"
        static let privacyButtonText: String = "Privacy"
        static let restoreButtonText: String = "Restore"
        static let termsButtonText: String = "Terms"
        
        static func underheaderText(with price: String) -> String {
            "Unlimited access for just \(price) per week."
        }
    }
    
    private lazy var headerTitleLabel: UILabel =
        .semiBoldTitleLabel(withText: TextConst.headerTitleText,
                            ofSize: 42.0)
        .textAlignment(.center)
        .numOfLines(2)
    
    private lazy var underHeaderLabel: UILabel =
    UILabel()
        .textAlignment(.center)
    
    private lazy var underHeaderPriceLabel: UILabel =
        .regularTitleLabel(withText: TextConst.underheaderText(with: "$6.99"),
                           ofSize: 15.0,
                           color: .appBlack.withAlphaComponent(0.6))
        .textAlignment(.center)
    
    private lazy var mainPaywallImageView: UIImageView =
    UIImageView(image: .paywallMain)
        .contentMode(.scaleAspectFill)
    
    private lazy var onbPageControl: OnboardingPageControlView =
    OnboardingPageControlView()
        .setup(currentPage: 3)
    
    private lazy var continueButton: ContinueButtonView = ContinueButtonView()
    
    private lazy var underButtonLabel: UILabel =
        .regularTitleLabel(withText: TextConst.underButtonText,
                           ofSize: 12.0,
                           color: .appBlack.withAlphaComponent(0.6))
    
    private var crossButton: UIButton = .crossButton()
    
    private var privacyButton: UIButton =
        .footerActionButton(title: TextConst.privacyButtonText)
    private var restoreButton: UIButton =
        .footerActionButton(title: TextConst.restoreButtonText)
    private var termsButton: UIButton =
        .footerActionButton(title: TextConst.termsButtonText)
    
    
    private var viewModel: PaywallProdTrialViewModelProtocol
    private var bag = DisposeBag()
    
    init(viewMode: PaywallProdTrialViewModelProtocol) {
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
        underHeaderLabel.attributedText = getAttributedUnderHeaderText()
    }
    
    private func bind() {
        viewModel.showCrossButton.subscribe { [weak self] _ in
            self?.crossButton.isHidden = false
        }
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
private extension PaywallProdTrialVC {
    
    func commonInit() {
        self.view.backgroundColor = .appBg
        self.crossButton.isHidden = true
        //add sub
        self.view.addSubview(headerTitleLabel)
        self.view.addSubview(underHeaderLabel)
        self.view.addSubview(mainPaywallImageView)
        self.view.addSubview(underHeaderPriceLabel)
        self.view.addSubview(onbPageControl)
        self.view.addSubview(continueButton)
        self.view.addSubview(underButtonLabel)
        self.view.addSubview(privacyButton)
        self.view.addSubview(restoreButton)
        self.view.addSubview(termsButton)
        self.view.addSubview(crossButton)
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
        underHeaderLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(headerTitleLabel.snp.bottom)
        }
        underHeaderPriceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(underHeaderLabel.snp.bottom)
        }
        mainPaywallImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(16.0)
            make.bottom.equalToSuperview().inset(213)
        }
        onbPageControl.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(40)
            make.bottom.equalToSuperview().inset(135.0)
        }
        continueButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16.0)
            make.height.equalTo(64)
            make.bottom.equalToSuperview().inset(47.0)
        }
        underButtonLabel.snp.makeConstraints { make in
            make.top.equalTo(continueButton.snp.bottom).offset(4.0)
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
    
    
    func getAttributedUnderHeaderText() -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = UIImage.paywallCheckbox
            .withTintColor(UIColor.appBlack.withAlphaComponent(0.6),
                           renderingMode: .alwaysOriginal)

        attachment.bounds = CGRect(
            x: 0,
            y: (underHeaderLabel.font.capHeight
                - (attachment.image?.size.height ?? 0)) / 2,
                                   width: attachment.image?.size.width ?? 0,
                                   height: attachment.image?.size.height ?? 0)

        let attributedString = NSMutableAttributedString(attachment: attachment)

        attributedString.append(NSAttributedString(string: " "))

        attributedString.append(NSAttributedString(
            string: TextConst.underHeaderText,
            attributes: [
                .foregroundColor: UIColor.appBlack.withAlphaComponent(0.6),
                .font: UIFont.appRegularFont(ofSize: 15)
            ]))

        return attributedString
    }
    
}

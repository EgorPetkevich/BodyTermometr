//
//  OnbThirdVC.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 13.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol OnbThirdVCViewModelProtocol {
    //In
    var continueButtonSubject: PublishSubject<Void> { get }
}

final class OnbThirdVC: UIViewController {
    
    private enum TextConst {
        static let headerTitleText: String = "Track & Analyze \n Your Temperature"
        static let underHeaderText: String =
        "Save your readings and easily track daily trends \n to better understand your health over time."
        
    }
    
    private lazy var headerTitleLabel: UILabel =
        .semiBoldTitleLabel(withText: TextConst.headerTitleText,
                            ofSize: 42.0)
        .numOfLines(2)
        .textAlignment(.center)
    private lazy var underHeaderTextLabel: UILabel =
        .regularTitleLabel(withText: TextConst.underHeaderText,
                           ofSize: 15.0,
                           color: .appBlack.withAlphaComponent(0.6))
        .numOfLines(3)
        .textAlignment(.center)
    
    private lazy var mainOnboardingImageView: UIImageView
    = UIImageView(image: .onbThird).contentMode(.scaleAspectFill)
    
    private lazy var onbPageControl: OnboardingPageControlView =
    OnboardingPageControlView()
        .setup(currentPage: 2)
    
    private lazy var continueButton: ContinueButtonView = ContinueButtonView()
    
    private var viewModel: OnbSecondViewModelProtocol
    
    private var bag = DisposeBag()
    
    init(viewModel: OnbSecondViewModelProtocol) {
        self.viewModel = viewModel
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
        self.view.backgroundColor = .appBg
        self.navigationItem.hidesBackButton = true
    }
    
    private func bind() {
        continueButton
            .tap
            .bind(to: viewModel.continueButtonSubject)
            .disposed(by: bag)
    }
    
}

// MARK: - Private
private extension OnbThirdVC {
    
    private func commonInit() {
        //add subs
        self.view.addSubview(headerTitleLabel)
        self.view.addSubview(underHeaderTextLabel)
        self.view.addSubview(mainOnboardingImageView)
        self.view.addSubview(onbPageControl)
        self.view.addSubview(continueButton)
    }
    
    private func setupSnapkitConstraints() {
        headerTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(86.0)
        }
        underHeaderTextLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(headerTitleLabel.snp.bottom)
        }
        mainOnboardingImageView.snp.makeConstraints { make in
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
        
    }
    
}




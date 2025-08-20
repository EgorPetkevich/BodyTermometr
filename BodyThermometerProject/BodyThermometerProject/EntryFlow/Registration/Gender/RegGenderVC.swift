//
//  RegGenderVC.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 17.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol RegGenderViewModelProtocol {
    //In
    var crossTapped: PublishSubject<Void> { get }
    var continueTapped: PublishSubject<Void> { get }
    var selectedGenderSubject: BehaviorSubject<Gender> { get }
}

final class RegGenderVC: UIViewController {
    
    private enum TextConst {
        static let titleText: String = "What’s your gender?"
        static let pageIndicatorText: String = "2/2"
    }
    
    private enum LayoutConst {
        static let crossButtonSize: CGFloat = 48.0
    }
    
    private lazy var pageControlView: RegistrationPageControlView =
    RegistrationPageControlView()
        .setup(currentPage: 1)
    
    private lazy var titleLabel: UILabel =
        .mediumTitleLabel(withText: TextConst.titleText, ofSize: 24.0)
    
    private lazy var pageIndicatorLabel: UILabel =
        .mediumTitleLabel(
            withText: TextConst.pageIndicatorText,
            ofSize: 18.0,
            color: .appGrey.alpa(0.6))
    
    private lazy var crossButton: UIButton =
    UIButton(type: .system)
        .setImage(.crossIconBlack)
        .setTintColor(.appBlack)
        .setBgColor(.appWhite)
    
    private lazy var genderCellsView: RegistrationGenderCellsView =
    RegistrationGenderCellsView()
    
    private lazy var continueButtonView: ContinueButtonView =
    ContinueButtonView()
    
    private var viewModel: RegGenderViewModelProtocol
    
    private var bag = DisposeBag()
    
    init(viewModel: RegGenderViewModelProtocol) {
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
        rx.hideKeyboardOnTap(disposeBag: bag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true,
                                                     animated: false)
    }
    
    private func bind() {
        continueButtonView
            .tap
            .bind(to: viewModel.continueTapped)
            .disposed(by: bag)
        
        genderCellsView
            .selectedGenderSubject
            .bind(to: viewModel.selectedGenderSubject)
            .disposed(by: bag)
        
        crossButton.rx.tap
            .bind(to: viewModel.continueTapped)
            .disposed(by: bag)
    }
    
}

//MARK: - Private
private extension RegGenderVC {
    
    func commonInit() {
        //add subs
        self.view.addSubview(pageControlView)
        self.view.addSubview(titleLabel)
        self.view.addSubview(pageIndicatorLabel)
        self.view.addSubview(crossButton)
        self.view.addSubview(continueButtonView)
        self.view.addSubview(genderCellsView)
    }
    
    func setupSnapkitConstraints() {
        pageControlView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(21)
            make.right.equalToSuperview().inset(62)
            make.left.equalToSuperview().inset(80.0)
        }
        pageIndicatorLabel.snp.makeConstraints { make in
            make.centerY.equalTo(pageControlView.snp.centerY)
            make.right.equalToSuperview().inset(16.0)
        }
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(142.0)
        }
        crossButton.snp.makeConstraints { make in
            make.size.equalTo(LayoutConst.crossButtonSize)
            make.left.equalToSuperview().inset(16.0)
            make.centerY.equalTo(pageControlView)
        }
        crossButton.radius = LayoutConst.crossButtonSize / 2
        genderCellsView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(16.0)
        }
        continueButtonView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16.0)
            make.bottom.equalToSuperview().inset(47.0)
        }
    }
    
}


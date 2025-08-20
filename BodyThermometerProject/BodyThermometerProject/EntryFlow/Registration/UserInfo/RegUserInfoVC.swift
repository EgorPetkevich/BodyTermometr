//
//  RegUserInfoVC.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 17.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol RegUserInfoViewModelProtocol {
    //In
    var keyBoardFrame: Observable<CGRect> { get }
    //Out
    var crossTapped: PublishSubject<Void> { get }
    var continueTapped: PublishSubject<Void> { get }
    var userNameSubject: BehaviorSubject<String?> { get }
    var userAgeSubject: BehaviorSubject<String?> { get }
}

final class RegUserInfoVC: UIViewController {
    
    private enum TextConst {
        static let titleText: String = "What’s your name and age?"
        static let pageIndicatorText: String = "1/2"
    }
    
    private enum LayoutConst {
        static let crossButtonSize: CGFloat = 48.0
    }
    
    private var contButtonButtomConstarint: Constraint?
    
    private lazy var pageControlView: RegistrationPageControlView =
    RegistrationPageControlView()
        .setup(currentPage: 0)
    
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
    
    private lazy var nameTextFieldView: RegistrationTextFieldView =
    RegistrationTextFieldView(type: .name)
    
    private lazy var ageTextFieldView: RegistrationTextFieldView =
    RegistrationTextFieldView(type: .age)
    
    private lazy var continueButtonView: ContinueButtonView =
    ContinueButtonView()
    
    private var viewModel: RegUserInfoViewModelProtocol
    
    private var bag = DisposeBag()
    
    init(viewModel: RegUserInfoViewModelProtocol) {
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
        crossButton.rx.tap
            .bind(to: viewModel.crossTapped)
            .disposed(by: bag)
        
        continueButtonView
            .tap
            .bind(to: viewModel.continueTapped)
            .disposed(by: bag)

        nameTextFieldView.textFieldTextObservable
            .bind(to: viewModel.userNameSubject)
            .disposed(by: bag)
        
        ageTextFieldView.textFieldTextObservable
            .bind(to: viewModel.userAgeSubject)
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

//MARK: - Private
private extension RegUserInfoVC {
    
    func commonInit() {
        //add subs
        self.view.addSubview(pageControlView)
        self.view.addSubview(titleLabel)
        self.view.addSubview(pageIndicatorLabel)
        self.view.addSubview(crossButton)
        self.view.addSubview(nameTextFieldView)
        self.view.addSubview(ageTextFieldView)
        self.view.addSubview(continueButtonView)
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
        nameTextFieldView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(36.0)
            make.horizontalEdges.equalToSuperview().inset(16.0)
        }
        ageTextFieldView.snp.makeConstraints { make in
            make.top.equalTo(nameTextFieldView.snp.bottom).offset(24.0)
            make.horizontalEdges.equalToSuperview().inset(16.0)
        }
        continueButtonView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16.0)
            contButtonButtomConstarint =
            make.bottom.equalToSuperview().inset(47.0).constraint
        }
    }
    
}

//
//  ProfileVC.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 20.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol ProfileViewModelProtocol {
    //Out
    var userInfoDTO: Observable<UserInfoDTO> { get }
    var keyBoardFrame: Observable<CGRect> { get }
    //In
    var backButtonTapped: PublishSubject<Void> { get }
    var saveButtonTapped: PublishSubject<Void> { get }
    var userNameSubject: BehaviorSubject<String?> { get }
    var userAgeSubject: BehaviorSubject<String?> { get }
    var userGenderSubject: BehaviorSubject<Gender> { get }
}

final class ProfileVC: UIViewController {
    
    private enum TextConst {
        static let titleText: String = "Profile"
        static let choosePhotoText: String = "Choose photo"
    }
    
    private enum LayoutConst {
        static let backButtonSize: CGSize = .init(width: 48.0, height: 48.0)
    }
    
    private lazy var titleLabel: UILabel =
        .mediumTitleLabel(withText: TextConst.titleText, ofSize: 24.0)
    
    private lazy var backButton: UIButton =
    UIButton(type: .system)
        .setImage(.arrowLeftIcon)
        .setBgColor(.appWhite)
    
    private lazy var userIconView: ProfileUserIconView = ProfileUserIconView()
    
    private lazy var choosePhotoButton: UIButton =
    UIButton(type: .system)
        .setImage(.cameraIcon)
        .setTitle(TextConst.choosePhotoText)
        .setTintColor(.appBlack)
    
    private lazy var userNameTextFieldView: UserNameTextFieldView =
    UserNameTextFieldView()
    
    private lazy var userAgeTextFieldView: UserAgeTextFieldView =
    UserAgeTextFieldView()
    
    private lazy var userGenderCellsView: ProfileGenderCellsView =
    ProfileGenderCellsView()
    
    private lazy var saveButton: ProfileSaveButtonView = ProfileSaveButtonView()
    
    private var saveButtonBottomConstraint: Constraint?
    
    private var viewModel: ProfileViewModelProtocol
    
    private var bag = DisposeBag()
    
    init(viewModel: ProfileViewModelProtocol) {
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
        self.view.backgroundColor = .appBg
        rx.hideKeyboardOnTap(disposeBag: bag)
    }
    
    private func bind() {
        viewModel
            .userInfoDTO
            .subscribe(onNext: { [weak self] dto in
                self?.setupUserInfo(with: dto)
            })
            .disposed(by: bag)
        
        backButton.rx.tap
            .bind(to: viewModel.backButtonTapped)
            .disposed(by: bag)
        
        saveButton.rx.tap
            .bind(to: viewModel.saveButtonTapped)
            .disposed(by: bag)
        
        userNameTextFieldView
            .textFieldTextObservable
            .bind(to: viewModel.userNameSubject)
            .disposed(by: bag)
        userAgeTextFieldView.textFieldTextObservable
            .bind(to: viewModel.userAgeSubject)
            .disposed(by: bag)
        userGenderCellsView
            .selectedGenderSubject
            .bind(to: viewModel.userGenderSubject)
            .disposed(by: bag)
        
        viewModel.keyBoardFrame
            .map { $0.height }
            .map { height -> CGFloat in
                height > 0 ? 24 + height : 47
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] inset in
                guard let self else { return }
                self.saveButtonBottomConstraint?.update(inset: inset)

                UIView.animate(withDuration: 0.25) {
                    self.view.layoutIfNeeded()
                }
            })
            .disposed(by: bag)
        
    }
    
}

//MARK: - Private
private extension ProfileVC {
    
    func commonInit() {
        self.view.addSubview(backButton)
        self.view.addSubview(titleLabel)
        self.view.addSubview(userIconView)
        self.view.addSubview(choosePhotoButton)
        self.view.addSubview(userNameTextFieldView)
        self.view.addSubview(userAgeTextFieldView)
        self.view.addSubview(userGenderCellsView)
        self.view.addSubview(saveButton)
    }
    
    func setupSnapKitConstraints() {
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(8.0)
            make.left.equalToSuperview().inset(16.0)
            make.size.equalTo(LayoutConst.backButtonSize)
        }
        backButton.radius = LayoutConst.backButtonSize.width / 2.0
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton.snp.centerY)
        }
        userIconView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(34.0)
        }
        choosePhotoButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(userIconView.snp.bottom).offset(4.0)
        }
        userNameTextFieldView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16.0)
            make.top.equalTo(choosePhotoButton.snp.bottom).offset(24.0)
        }
        userAgeTextFieldView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16.0)
            make.top.equalTo(userNameTextFieldView.snp.bottom).offset(16.0)
        }
        userGenderCellsView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16.0)
            make.top.equalTo(userAgeTextFieldView.snp.bottom).offset(16.0)
        }
        saveButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16.0)
            saveButtonBottomConstraint =
            make.bottom.equalToSuperview().inset(47.0).constraint
        }
        
    }
    
    private func setupUserInfo(with dto: UserInfoDTO) {
        userNameTextFieldView.textFieldText = dto.userName
        userAgeTextFieldView.textFieldText = dto.userAge
        userIconView.icon = dto.gender?.icon
        userGenderCellsView.selectedGenderSubject.onNext(dto.gender ?? .female)
    }
    
}

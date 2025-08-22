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
    var iconImage: Observable<UIImage> { get }
    //In
    var backButtonTapped: PublishSubject<Void> { get }
    var choosePhotoButtonTapped: PublishSubject<Void> { get }
    var saveButtonTapped: PublishSubject<Void> { get }
    var userNameSubject: BehaviorSubject<String?> { get }
    var userAgeSubject: BehaviorSubject<String?> { get }
    var userGenderSubject: BehaviorSubject<Gender> { get }
    
    func viewDidLoad()
}

final class ProfileVC: UIViewController {
    
    private enum TextConst {
        static let titleText: String = "Profile"
        static let choosePhotoText: String = " " + "Choose photo"
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
        .setTintColor(.appBlack)
    
    private lazy var userIconView: ProfileUserIconView = ProfileUserIconView()
    
    private lazy var choosePhotoButton: UIButton =
    UIButton(type: .system)
        .setImage(.cameraIcon)
        .setTitle(TextConst.choosePhotoText)
        .setFont(.appSemiBoldFont(ofSize: 14.0))
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
    
    private var hasCustomIcon = false
    
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
        viewModel.viewDidLoad()
        self.view.backgroundColor = .appBg
        rx.hideKeyboardOnTap(disposeBag: bag)
    }
    
    private func bind() {
        bindViewModelOutputs()
        bindActions()
        bindTextInputs()
        bindGenderIconUpdates()
        bindKeyboardInset()
        bindAgeFieldEditingAnimation()
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
            make.horizontalEdges.equalToSuperview()
            saveButtonBottomConstraint =
            make.bottom.equalToSuperview().inset(43.0).constraint
        }
        
    }
    
    private func setupUserInfo(with dto: UserInfoDTO) {
        userNameTextFieldView.textFieldText = dto.userName
        userAgeTextFieldView.textFieldText = dto.userAge
        if !hasCustomIcon {
            userIconView.icon = dto.gender?.icon
        }
        userGenderCellsView.selectedGenderSubject.onNext(dto.gender ?? .female)
    }
    
    // MARK: - Bindings split
    func bindViewModelOutputs() {
        viewModel
            .userInfoDTO
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { owner, dto in
                owner.setupUserInfo(with: dto)
            })
            .disposed(by: bag)

        viewModel.iconImage
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { owner, image in
                owner.hasCustomIcon = true
                owner.userIconView.iconImageView.image = image
            })
            .disposed(by: bag)
    }

    func bindActions() {
        backButton.rx.tap
            .bind(to: viewModel.backButtonTapped)
            .disposed(by: bag)

        choosePhotoButton.rx.tap
            .bind(to: viewModel.choosePhotoButtonTapped)
            .disposed(by: bag)

        userIconView.tap
            .bind(to: viewModel.choosePhotoButtonTapped)
            .disposed(by: bag)

        saveButton.onTap
            .bind(to: viewModel.saveButtonTapped)
            .disposed(by: bag)
    }

    func bindTextInputs() {
        userNameTextFieldView
            .textFieldTextObservable
            .bind(to: viewModel.userNameSubject)
            .disposed(by: bag)

        userAgeTextFieldView
            .textFieldTextObservable
            .bind(to: viewModel.userAgeSubject)
            .disposed(by: bag)

        userGenderCellsView
            .selectedGenderSubject
            .bind(to: viewModel.userGenderSubject)
            .disposed(by: bag)
    }

    func bindGenderIconUpdates() {
        userGenderCellsView
            .selectedGenderSubject
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { owner, gender in
                if !owner.hasCustomIcon {
                    owner.userIconView.icon = gender.icon
                }
            })
            .disposed(by: bag)
    }

    func bindKeyboardInset() {
        viewModel.keyBoardFrame
            .map { $0.height }
            .map { $0 > 0 ? $0 : 43 }
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { owner, inset in
                owner.saveButtonBottomConstraint?.update(inset: inset)
                UIView.animate(withDuration: 0.25) {
                    owner.view.layoutIfNeeded()
                }
            })
            .disposed(by: bag)
    }

    func bindAgeFieldEditingAnimation() {
        userAgeTextFieldView.textField.rx.controlEvent(.editingDidBegin)
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.setEditMode(true)
            })
            .disposed(by: bag)

        userAgeTextFieldView.textField.rx.controlEvent(.editingDidEnd)
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.setEditMode(false)
            })
            .disposed(by: bag)
    }

    // MARK: - UI state helpers
    func setEditMode(_ editing: Bool) {
        userIconView.isHidden = editing
        choosePhotoButton.isHidden = editing
        saveButton.backgroundColor = editing ? .appBgBlur : .appBg

        userNameTextFieldView.snp.remakeConstraints { make in
            if editing {
                make.top.equalTo(view.snp.top).inset(106.0)
            } else {
                make.top.equalTo(choosePhotoButton.snp.bottom).offset(24.0)
            }
            make.horizontalEdges.equalToSuperview().inset(16.0)
        }

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}

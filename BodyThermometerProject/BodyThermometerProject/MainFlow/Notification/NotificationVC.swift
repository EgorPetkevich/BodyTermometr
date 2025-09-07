//
//  NotificationVC.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 25.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol NotificationViewModelProtocol {
    // Out
    var notificationState: Driver<Bool> { get }
    var switchState: Driver<Bool> { get }
    var isSwitchEnabled: Driver<Bool> { get }
    // In
    var backButtonTapped: PublishRelay<Void> { get }
    var viewWillAppear: PublishRelay<Void> { get }
    var switchToggled: PublishRelay<Bool> { get }
}

final class NotificationVC: UIViewController {
    
    private enum TextConst {
        static let titleText: String = "Notification"
        static let notificationText: String = "Notification"
        static let subNotificationText: String = "Get reminders to check your body temperature and \nheart rate — never miss a reading."
    }
    
    private enum LayoutConst {
        static let backButtonSize: CGFloat = 48.0
    }
    
    private lazy var titleLabel: UILabel =
        .mediumTitleLabel(withText: TextConst.titleText, ofSize: 24.0)
    
    private lazy var notificationLabel: UILabel =
        .mediumTitleLabel(withText: TextConst.notificationText, ofSize: 18.0)
    
    private lazy var subNotificationLabel: UILabel =
        .regularTitleLabel(withText: TextConst.subNotificationText,
                           ofSize: 12.0,
                           color: .appGrey)
        .numOfLines(2)
    private lazy var notificationSwitch: UISwitch = .init()
    
    private lazy var backArrowButton: UIButton =
    UIButton(type: .system)
        .setImage(.arrowIconBack)
        .setBgColor(.appWhite)
        .setTintColor(.appBlack)
    
    
    private var viewModel: NotificationViewModelProtocol
    
    private var bag = DisposeBag()
    
    init(viewModel: NotificationViewModelProtocol) {
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true,
                                                     animated: false)
        viewModel.viewWillAppear.accept(())
    }
    
    private func bind() {
        backArrowButton.rx.tap
            .bind(to: viewModel.backButtonTapped)
            .disposed(by: bag)
        
        viewModel.switchState
            .drive(notificationSwitch.rx.isOn)
            .disposed(by: bag)
        
        viewModel.isSwitchEnabled
            .drive(notificationSwitch.rx.isEnabled)
            .disposed(by: bag)
        
        notificationSwitch.rx.isOn
            .skip(1)
            .bind(to: viewModel.switchToggled)
            .disposed(by: bag)
        viewModel.switchState
            .map { $0 } 
            .drive(subNotificationLabel.rx.isHidden)
            .disposed(by: bag)
    }
    
}

//MARK: - Private
private extension NotificationVC {
    
    func commonInit() {
        self.view.addSubview(titleLabel)
        self.view.addSubview(backArrowButton)
        self.view.addSubview(notificationLabel)
        self.view.addSubview(subNotificationLabel)
        self.view.addSubview(notificationSwitch)
    }
    
    func setupSnapKitConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(17.0)
        }
        backArrowButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16.0)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(8.0)
            make.size.equalTo(LayoutConst.backButtonSize)
        }
        backArrowButton.radius = LayoutConst.backButtonSize / 2
        notificationLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16.0)
            make.top.equalToSuperview().inset(142.0)
        }
        subNotificationLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16.0)
            make.top.equalTo(notificationLabel.snp.bottom).offset(8.0)
        }
        notificationSwitch.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16.0)
            make.top.equalToSuperview().inset(142.0)
        }
    }
    
    
}

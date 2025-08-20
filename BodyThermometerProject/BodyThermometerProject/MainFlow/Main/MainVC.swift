//
//  MainVC.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 18.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol MainViewModelProtocol {
    //Out
    var userInfoDTO: Observable<UserInfoDTO> { get }
    //In
    var profileButtonTapped: PublishSubject<Void> { get }
}

final class MainVC: UIViewController {
    
    private enum TextConst {
        static let titleText: String = "How Are You \nFeeling Today?"
        
        static let hiText: String = "Hi there!"
        static func hiUserText(userName: String) -> String {
            userName.isEmpty ? "Hi there!" : "Hi there, \(userName)!"
        }
    }
    
    private lazy var titleLabel: UILabel =
        .semiBoldTitleLabel(withText: TextConst.titleText, ofSize: 42.0)
        .numOfLines(2)
        .textAlignment(.left)
    
    private lazy var hiTitleLabel: UILabel =
        .regularTitleLabel(withText: TextConst.hiText, ofSize: 15.0)
    
    private lazy var profileButton: MainProfileButtonView = MainProfileButtonView()
    private lazy var menuButton: MainMenuButtonView = MainMenuButtonView()
    
    private lazy var bodyTempView: MainBodyTempView = MainBodyTempView()
    private lazy var statDataView: MainStatisticsDataView = MainStatisticsDataView()
    private lazy var heartRateView: MainHeartRateView = MainHeartRateView()
    
    private var viewModel: MainViewModelProtocol
    
    private var bag = DisposeBag()
    
    init(viewModel: MainViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        commonInit()
        setupSnapKitConstrainsts()
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
    }
    
    private func bind() {
        viewModel
            .userInfoDTO
            .subscribe(onNext: { [weak self] dto in
                self?.setupUserInfo(with: dto)
            })
            .disposed(by: bag)
        profileButton.tap
            .bind(to: viewModel.profileButtonTapped)
            .disposed(by: bag)
    }
    
}

//MARK: - Private
private extension MainVC {
    
    func commonInit() {
        self.view.addSubview(hiTitleLabel)
        self.view.addSubview(profileButton)
        self.view.addSubview(menuButton)
        self.view.addSubview(titleLabel)
        self.view.addSubview(bodyTempView)
        self.view.addSubview(statDataView)
        self.view.addSubview(heartRateView)
    }
    
    func setupSnapKitConstrainsts() {
        profileButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16.0)
            make.top.equalToSuperview().inset(62.0)
        }
        menuButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16.0)
            make.top.equalToSuperview().inset(62.0)
        }
        hiTitleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(profileButton.snp.centerY)
            make.left.equalTo(profileButton.snp.right).offset(8.0)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(profileButton.snp.bottom).offset(16.0)
            make.left.equalToSuperview().inset(16.0)
        }
        bodyTempView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16.0)
            make.right.equalTo(view.snp.centerX).inset(4.0)
            make.top.equalTo(titleLabel.snp.bottom).offset(24.0)
        }
        statDataView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16.0)
            make.left.equalTo(view.snp.centerX).offset(4.0)
            make.top.equalTo(titleLabel.snp.bottom).offset(24.0)
        }
        heartRateView.snp.makeConstraints { make in
            make.top.equalTo(bodyTempView.snp.bottom).offset(8.0)
            make.horizontalEdges.equalToSuperview().inset(16.0)
        }
    }
    
    private func setupUserInfo(with dto: UserInfoDTO) {
        hiTitleLabel.text = TextConst.hiUserText(userName: dto.userName)
        profileButton.icon = dto.gender?.icon
       
    }
    
}

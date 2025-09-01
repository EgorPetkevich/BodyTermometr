//
//  MainVM.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 18.08.25.
//

import Foundation
import RxSwift
import RxCocoa

protocol MainRouterProtocol {
    func openProfile()
    func openSettings()
    func openHeartRate()
    func openTemperatureInput()
}

protocol MainRealmDataManagerUseCaseProtocol {
    var userInfo: Observable<UserInfoDTO> { get }
}

protocol MainFileManagerServiceUseCaseProtocol {
    func getIconImage() -> Observable<UIImage>?
}

final class MainVM: MainViewModelProtocol {
    //Out
    @Subject(value: UserInfoDTO(UserInfoModel()))
    var userInfoDTO: Observable<UserInfoDTO>
    @Subject()
    var iconImage: Observable<UIImage>
    //In
    var profileButtonTapped: PublishSubject<Void> = .init()
    var settingsButtonTapped: PublishSubject<Void> = .init()
    var heartRateTapped: PublishSubject<Void> = .init()
    var bodyTempTapped: PublishSubject<Void> = .init()
    
    private let router: MainRouterProtocol
    private let realmDataManager: MainRealmDataManagerUseCaseProtocol
    private var fileManageService: MainFileManagerServiceUseCaseProtocol
    
    private let bag = DisposeBag()
    
    init(
        router: MainRouterProtocol,
        realmDataManager: MainRealmDataManagerUseCaseProtocol,
        fileManageService: MainFileManagerServiceUseCaseProtocol
    ) {
        self.router = router
        self.realmDataManager = realmDataManager
        self.fileManageService = fileManageService
        bind()
    }
    
    func viewWillAppear() {
        fileManageService
            .getIconImage()?
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] img in
                self?._iconImage.rx.onNext(img)
            })
            .disposed(by: bag)
    }
    
    private func bind() {
        realmDataManager
            .userInfo
            .bind(to: _userInfoDTO.rx)
            .disposed(by: bag)
        profileButtonTapped.subscribe(onNext: { [weak self] in
            self?.router.openProfile()
        })
        .disposed(by: bag)
        settingsButtonTapped.subscribe(onNext: { [weak self] in
            self?.router.openSettings()
        })
        .disposed(by: bag)
        heartRateTapped.subscribe(onNext: { [weak self] in
            self?.router.openHeartRate()
        })
        .disposed(by: bag)
        bodyTempTapped.subscribe(onNext: { [weak self] in
            self?.router.openTemperatureInput()
        })
    }
    
}

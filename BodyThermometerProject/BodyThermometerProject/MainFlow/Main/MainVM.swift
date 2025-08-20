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
}

protocol MainRealmDataManagerUseCaseProtocol {
    var userInfo: Observable<UserInfoDTO> { get }
}

final class MainVM: MainViewModelProtocol {
    //Out
    @Subject(value: UserInfoDTO(UserInfoModel()))
    var userInfoDTO: Observable<UserInfoDTO>
    //In
    var profileButtonTapped: PublishSubject<Void> = .init()
    
    private let router: MainRouterProtocol
    private let realmDataManager: MainRealmDataManagerUseCaseProtocol
    
    private let bag = DisposeBag()
    
    init(
        router: MainRouterProtocol,
        realmDataManager: MainRealmDataManagerUseCaseProtocol
    ) {
        self.router = router
        self.realmDataManager = realmDataManager
        bind()
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
        
    }
    
}

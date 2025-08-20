//
//  ProfileVM.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 20.08.25.
//

import Foundation
import RxSwift
import RxCocoa

protocol ProfileRouterProtocol {
    func dismiss()
}

protocol ProfileRealmDataManagerUseCaseProtocol {
    var userInfo: Observable<UserInfoDTO> { get }
    func saveUserInfo(name: String, age: String, gender: Gender)
}

protocol ProfileKeyBoardHelperServiceUseCaseProtocol {
    var frame: Observable<CGRect> { get }
}

final class ProfileVM: ProfileViewModelProtocol {
    
    //Out
    @Subject(value: UserInfoDTO(UserInfoModel()))
    var userInfoDTO: Observable<UserInfoDTO>
    @Subject()
    var keyBoardFrame: Observable<CGRect>
    //In
    var backButtonTapped: PublishSubject<Void> = .init()
    var saveButtonTapped: PublishSubject<Void> = .init()
    var userNameSubject: BehaviorSubject<String?> = .init(value: "UserName")
    var userAgeSubject: BehaviorSubject<String?> = .init(value: "")
    var userGenderSubject: BehaviorSubject<Gender> = .init(value: .female)
    
    private var router: ProfileRouterProtocol
    private var realmDataManager: ProfileRealmDataManagerUseCaseProtocol
    private var keyboardHelper: ProfileKeyBoardHelperServiceUseCaseProtocol
    
    
    private var bag = DisposeBag()
    
    init(router: ProfileRouterProtocol,
         realmDataManager: ProfileRealmDataManagerUseCaseProtocol,
         keyboardHelper: ProfileKeyBoardHelperServiceUseCaseProtocol) {
        self.router = router
        self.realmDataManager = realmDataManager
        self.keyboardHelper = keyboardHelper
        bind()
    }
    
    private func bind() {
        backButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.router.dismiss()
            })
            .disposed(by: bag)
        
        realmDataManager
            .userInfo
            .bind(to: _userInfoDTO.rx)
            .disposed(by: bag)
        
        let latestForm = Observable
            .combineLatest(
                userNameSubject.compactMap { $0 },
                userAgeSubject.compactMap { $0 },
                userGenderSubject.map { $0 }
            )
            .map { name, age, gender in
                (name.trimmingCharacters(in: .whitespacesAndNewlines),
                 age.trimmingCharacters(in: .whitespacesAndNewlines),
                 gender)
            }
        
        saveButtonTapped
            .withLatestFrom(latestForm)
            .filter { name, age, gender in
                !name.isEmpty && !age.isEmpty
            }
            .do(onNext: { [weak self] name, age, gender in
                self?.realmDataManager.saveUserInfo(name: name,
                                                    age: age,
                                                    gender: gender)
            })
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.router.dismiss()
            })
            .disposed(by: bag)
            
        keyboardHelper
            .frame
            .bind(to: _keyBoardFrame.rx)
            .disposed(by: bag)
    }
    
    
}

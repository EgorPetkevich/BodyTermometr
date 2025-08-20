//
//  RegUserInfoVM.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 17.08.25.
//

import UIKit
import RxSwift
import RealmSwift


protocol RegUserInfoRouterProtocol {
    func continueTapped()
    func crossTapped()
}

protocol RegUserInfoRealDataManagerUseCaseProtocol {
    func saveUserInfo(name: String, age: String)
}

protocol RegUserInfoKeyBoardHelperServiceUseCaseProtocol {
    var frame: Observable<CGRect> { get }
}

final class RegUserInfoVM: RegUserInfoViewModelProtocol {
    //Out
    @Subject()
    var keyBoardFrame: Observable<CGRect>
    //In
    var crossTapped: PublishSubject<Void> = .init()
    var continueTapped: PublishSubject<Void> = .init()
    var userNameSubject: BehaviorSubject<String?> = .init(value: "UserName")
    var userAgeSubject: BehaviorSubject<String?> = .init(value: "")
    
    private var router: RegUserInfoRouterProtocol
    
    private var keyboardHelper: RegUserInfoKeyBoardHelperServiceUseCaseProtocol
    private var realmDataManager: RegUserInfoRealDataManagerUseCaseProtocol
    
    private var bag = DisposeBag()
    
    init(router: RegUserInfoRouterProtocol,
         keyBoardHelper: RegUserInfoKeyBoardHelperServiceUseCaseProtocol,
         realmDataManager: RegUserInfoRealDataManagerUseCaseProtocol) {
        self.router = router
        self.keyboardHelper = keyBoardHelper
        self.realmDataManager = realmDataManager
        bind()
    }
    
    private func bind() {
        keyboardHelper
            .frame
            .bind(to: _keyBoardFrame.rx)
            .disposed(by: bag)
        
        let latestForm = Observable
            .combineLatest(
                userNameSubject.compactMap { $0 },
                userAgeSubject.compactMap { $0 }
            )
            .map { name, age in
                (name.trimmingCharacters(in: .whitespacesAndNewlines),
                 age.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        crossTapped
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.router.crossTapped()
            })
            .disposed(by: bag)
        
        continueTapped
            .withLatestFrom(latestForm)
            .filter { userName, age in
                !userName.isEmpty && !age.isEmpty
            }
            .do(onNext: { [weak self] name, age in
                self?.realmDataManager.saveUserInfo(name: name, age: age)
            })
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.router.continueTapped()
            })
            .disposed(by: bag)
    }

    
    
}

//
//  RegGenderVM.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 17.08.25.
//

import UIKit
import RxSwift

protocol RegGenderRouterProtocol {
    func continueTapped()
    func crossTapped()
}

protocol RegGenderRealDataManagerUseCaseProtocol {
    func saveGender(_ gender: Gender)
}

final class RegGenderVM: RegGenderViewModelProtocol {
    
    //In
    var crossTapped: PublishSubject<Void> = .init()
    var continueTapped: PublishSubject<Void> = .init()
    var selectedGenderSubject: BehaviorSubject<Gender> = .init(value: .female)
    
    private var router: RegGenderRouterProtocol
    private var realmDataManager: RegGenderRealDataManagerUseCaseProtocol
    
    private var bag = DisposeBag()
    
    init(router: RegGenderRouterProtocol,
         realDataManager: RegGenderRealDataManagerUseCaseProtocol) {
        self.router = router
        self.realmDataManager = realDataManager
        bind()
    }
    
    private func bind() {
        crossTapped
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.router.crossTapped()
            })
            .disposed(by: bag)
            
        continueTapped
            .withLatestFrom(selectedGenderSubject)
            .do(onNext: { [weak self] gender in
                UDManagerService.setIsUserRegistrated(true)
                self?.realmDataManager.saveGender(gender)
            })
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] _ in
                self?.router.continueTapped()
            })
            .disposed(by: bag)
    }
    
    
}

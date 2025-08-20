//
//  OnbThirdVM.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 14.08.25.
//

import UIKit
import RxSwift
import RxCocoa

protocol OnbThirdRouterProtocol {
    func goNext()
}

final class OnbThirdVM: OnbSecondViewModelProtocol {
    
    //In
    var continueButtonSubject: PublishSubject<Void> = .init()
    
    private var router: OnbThirdRouterProtocol
    
    private var bag = DisposeBag()
    
    init(router: OnbThirdRouterProtocol) {
        self.router = router
        bind()
    }
    
    func bind() {
        continueButtonSubject
            .subscribe(onNext: { [weak self] in
                self?.router.goNext()
            })
            .disposed(by: bag)
    }
    
}

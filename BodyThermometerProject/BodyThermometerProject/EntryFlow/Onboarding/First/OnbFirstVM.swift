//
//  FirstScreenOnboardingVM.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 13.08.25.
//

import UIKit
import RxSwift

protocol OnbFirstRouterProtocol {
    func goNext()
}

final class OnbFirstVM: OnbFirstViewModelProtocol {
    
    //In
    var continueButtonSubject: PublishSubject<Void> = .init()
    
    private var router: OnbFirstRouterProtocol
    
    private var bag = DisposeBag()
    
    init(router: OnbFirstRouterProtocol) {
        self.router = router
        bind()
    }
    
    private func bind() {
        continueButtonSubject
            .subscribe(onNext: { [weak self] in
                self?.router.goNext()
            })
            .disposed(by: bag)
    }
    
    
}

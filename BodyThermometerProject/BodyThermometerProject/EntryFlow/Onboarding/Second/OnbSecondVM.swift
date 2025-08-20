//
//  SecondScreenOnbordingVM.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 14.08.25.
//

import UIKit
import RxSwift
import RxCocoa

protocol OnbSecondRouterProtocol {
    func goNext()
}

final class OnbSecondVM: OnbSecondViewModelProtocol {
    
    //In
    var continueButtonSubject: PublishSubject<Void> = .init()
    
    private var router: OnbSecondRouterProtocol
    
    private var bag = DisposeBag()
    
    init(router: OnbSecondRouterProtocol) {
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

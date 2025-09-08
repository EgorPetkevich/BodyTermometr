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

protocol OnbThirdApphudManagerUseCaseProtocol {
    var config: RemoteConfig { get }
}

final class OnbThirdVM: OnbThirdViewModelProtocol {
    
    //Out
    @Relay(value: 1.0)
    var onbSubtitleAlphaRelay: Observable<Double>
    @Relay(value: nil)
    var onbButtonTitle: Observable<String?>
    @Relay(value: false)
    var isPagingEnabledRelay: Observable<Bool>
    
    //In
    var continueButtonSubject: PublishSubject<Void> = .init()
    
    private var router: OnbThirdRouterProtocol
    private var apphudManager: OnbThirdApphudManagerUseCaseProtocol
    
    private var bag = DisposeBag()
    
    init(router: OnbThirdRouterProtocol,
         apphudManager: OnbThirdApphudManagerUseCaseProtocol) {
        self.router = router
        self.apphudManager = apphudManager
        _onbSubtitleAlphaRelay.rx.accept(apphudManager.config.onboardingSubtitleAlpha)
        _onbButtonTitle.rx.accept(apphudManager.config.onboardingButtonTitle)
        _isPagingEnabledRelay.rx.accept(apphudManager.config.isPagingEnabled)
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

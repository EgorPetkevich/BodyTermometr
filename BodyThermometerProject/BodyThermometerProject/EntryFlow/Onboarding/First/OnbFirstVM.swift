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

protocol OnbFirstApphudManagerUseCaseProtocol {
    var config: RemoteConfig { get }
}

final class OnbFirstVM: OnbFirstViewModelProtocol {
    
    //Out
    @Relay(value: 1.0)
    var onbSubtitleAlphaRelay: Observable<Double>
    @Relay(value: nil)
    var onbButtonTitle: Observable<String?>
    @Relay(value: false)
    var isPagingEnabledRelay: Observable<Bool>
    
    //In
    var continueButtonSubject: PublishSubject<Void> = .init()
    
    private var router: OnbFirstRouterProtocol
    private var apphudManager: OnbFirstApphudManagerUseCaseProtocol
    
    private var bag = DisposeBag()
    
    init(router: OnbFirstRouterProtocol,
         apphudManager: OnbFirstApphudManagerUseCaseProtocol) {
        self.router = router
        self.apphudManager = apphudManager
        _onbSubtitleAlphaRelay.rx.accept(apphudManager.config.onboardingSubtitleAlpha)
        _onbButtonTitle.rx.accept(apphudManager.config.onboardingButtonTitle)
        _isPagingEnabledRelay.rx.accept(apphudManager.config.isPagingEnabled)
        
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

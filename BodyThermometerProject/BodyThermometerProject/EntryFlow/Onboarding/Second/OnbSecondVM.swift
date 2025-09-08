//
//  SecondScreenOnbordingVM.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 14.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import StoreKit

protocol OnbSecondRouterProtocol {
    func goNext()
}

protocol OnbSecondApphudManagerUseCaseProtocol {
    var config: RemoteConfig { get }
}


final class OnbSecondVM: OnbSecondViewModelProtocol {
    
    //Out
    @Relay(value: 1.0)
    var onbSubtitleAlphaRelay: Observable<Double>
    @Relay(value: nil)
    var onbButtonTitle: Observable<String?>
    @Relay(value: false)
    var isPagingEnabledRelay: Observable<Bool>
    @Relay(value: false)
    var isReviewEnabledRealy: Observable<Bool>
    
    //In
    var continueButtonSubject: PublishSubject<Void> = .init()
    
    private var router: OnbSecondRouterProtocol
    private var apphudManager: OnbSecondApphudManagerUseCaseProtocol
    
    private var bag = DisposeBag()
    
    init(router: OnbSecondRouterProtocol,
         apphudManager: OnbSecondApphudManagerUseCaseProtocol) {
        self.router = router
        self.apphudManager = apphudManager
        _onbSubtitleAlphaRelay.rx.accept(apphudManager.config.onboardingSubtitleAlpha)
        _onbButtonTitle.rx.accept(apphudManager.config.onboardingButtonTitle)
        _isPagingEnabledRelay.rx.accept(apphudManager.config.isPagingEnabled)
        _isReviewEnabledRealy.rx.accept(apphudManager.config.isReviewEnabled)
        bind()
    }
    
    private func bind() {
        continueButtonSubject
            .subscribe(onNext: { [weak self] in
                self?.router.goNext()
            })
            .disposed(by: bag)
        isReviewEnabledRealy
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { enable in
                if enable == false { return }
                SKStoreReviewController.requestReviewInCurrentScene()
            })
            .disposed(by: bag)
    }
    
    
}

//
//  PaywallProdTrialVM.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 14.08.25.
//

import UIKit
import RxSwift
import ApphudSDK

protocol PaywallProdTrialRouterProtocol {
    func finish()
}

protocol PaywallProdTrialApphudManagerUseCaseProtocol {
    var config: RemoteConfig { get }

    func getTrialPrice() -> String?
    func makePurchase() -> Single<ApphudSubscription>
    func restorePurchases() -> Single<Bool>
}

protocol PaywallProdTrialAlertServiceUseCaseProtocol {
    func showAlert(title: String,
                   message: String,
                   cancelTitle: String,
                   okTitle: String,
                   okHandler: @escaping () -> Void)
}

final class PaywallProdTrialVM: PaywallProdTrialViewModelProtocol {
    private enum PaywallActions {
        case continueDidTap
        case restoreDidTap
    }
    
    //Out
    @Subject()
    var showCrossButton: Observable<Void>
    @Relay(value: nil)
    var trialPriceRelay: Observable<String?>
    @Relay(value: nil)
    var paywallButtonTitleRelay: Observable<String?>
    @Relay(value: false)
    var isPagingEnabledRelay: Observable<Bool>
    //In
    var crossTapped: PublishSubject<Void> = .init()
    var viewDidLoad: PublishSubject<Void> = .init()
    var didSelectPrivacy: PublishSubject<Void> = .init()
    var didSelectRestore: PublishSubject<Void> = .init()
    var didSelectTerms: PublishSubject<Void> = .init()
    var makePurchaseTapped: PublishSubject<Void> = .init()
    
    private let apphudManager: PaywallProdTrialApphudManagerUseCaseProtocol
    private let alertService: PaywallProdTrialAlertServiceUseCaseProtocol
    
    private let router: PaywallProdTrialRouterProtocol
    
    private var bag = DisposeBag()
    
    init(router: PaywallProdTrialRouterProtocol,
         apphudManager: PaywallProdTrialApphudManagerUseCaseProtocol,
         alertService: PaywallProdTrialAlertServiceUseCaseProtocol) {
        self.router = router
        self.apphudManager = apphudManager
        self.alertService = alertService
        _trialPriceRelay.rx.accept(apphudManager.getTrialPrice())
        _paywallButtonTitleRelay.rx.accept(apphudManager.config.onboardingButtonTitle)
        _isPagingEnabledRelay.rx.accept(apphudManager.config.isPagingEnabled)
        bind()
    }
    
    private func bind() {
        viewDidLoad
            .flatMapLatest { _ in
                Observable<Void>.just(())
                    .delay(.seconds(
                        Int(self.apphudManager.config.onboardingCloseDelay)), scheduler: MainScheduler.instance)
            }
            .bind(to: _showCrossButton.rx)
            .disposed(by: bag)
        
        makePurchaseTapped
            .subscribe(onNext: { [weak self]  in
                guard let self else { return }
                apphudManager.makePurchase()
                    .subscribe(
                    onSuccess: { _ in
                        UDManagerService.setIsPremium(true)
                        self.router.finish()
                    },
                    onFailure: { _ in
                        self.showErrorMessage(from: .continueDidTap)
                    }
                    
                ).disposed(by: bag)
                
            })
            .disposed(by: bag)
        
        crossTapped
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                UDManagerService.setIsOnboardingShown(true)
                self?.router.finish()
            })
            .disposed(by: bag)
        
        didSelectTerms.subscribe(onNext: { _ in
            if let url = URL(string:  AppConfig.Settings.termsOfUseLink) {
                UIApplication.shared.open(url)
            }
        })
        .disposed(by: bag)
        
        didSelectPrivacy.subscribe(onNext: { _ in
            if let url = URL(string: AppConfig.Settings.privacyPolicyLink) {
                UIApplication.shared.open(url)
            }
        })
        .disposed(by: bag)
        
        didSelectRestore.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            apphudManager.restorePurchases()
             
                .subscribe(onSuccess: { success in
                    if success {
                        UDManagerService.setIsPremium(true)
                        self.router.finish()
                    } else {
                        self.showErrorMessage(from: .restoreDidTap)
                    }
                    
                }, onFailure: { _ in
                    self.showErrorMessage(from: .restoreDidTap)
                })
                .disposed(by: bag)
        })
        .disposed(by: bag)
            
    }
    
}

//MARK: - Alert Service Use Case
extension PaywallProdTrialVM {
    
    private func showErrorMessage(from action: PaywallActions) {
        alertService.showAlert(title: "Oops...",
                               message: "Something went wrong. Please try again",
                               cancelTitle: "Cancel", okTitle: "Try again")
        { [weak self] in
            switch action {
            case .continueDidTap:
                self?.makePurchaseTapped.onNext(())
            case .restoreDidTap:
                self?.didSelectRestore.onNext(())
            }
        }
    }
    
}

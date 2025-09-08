//
//  PaywallRevVM.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 15.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import ApphudSDK


protocol PaywallRevRouterProtocol {
    func finish()
}

protocol PaywallRevApphudManagerUseCaseProtocol {
    var config: RemoteConfig { get }
    func getTrialPrice() -> String?
    func getProdPrice() -> String?
    func makePurchase(isTrial: Bool) -> Single<ApphudSubscription>
    func restorePurchases() -> Single<Bool>
}

protocol PaywallRevAlertServiceUseCaseProtocol {
    func showAlert(title: String,
                   message: String,
                   cancelTitle: String,
                   okTitle: String,
                   okHandler: @escaping () -> Void)
}

final class PaywallRevVM: PaywallRevViewModelProtocol {
    
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
    var prodPriceRelay: Observable<String?>
    @Relay(value: nil)
    var paywallButtonTitleRelay: Observable<String?>
    //In
    var crossTapped: PublishSubject<Void> = .init()
    var viewDidLoad: PublishSubject<Void> = .init()
    var didSelectPrivacy: PublishSubject<Void> = .init()
    var didSelectRestore: PublishSubject<Void> = .init()
    var didSelectTerms: PublishSubject<Void> = .init()
    var makePurchaseTapped: PublishSubject<Void> = .init()
    var isTrialRelay: BehaviorRelay<Bool> = .init(value: false)
    
    private let router: PaywallRevRouterProtocol
    private let apphudManager: PaywallRevApphudManagerUseCaseProtocol
    private let alertService: PaywallRevAlertServiceUseCaseProtocol
    
    private var bag = DisposeBag()
    
    init(router: PaywallRevRouterProtocol,
         apphudManager: PaywallRevApphudManagerUseCaseProtocol,
         alertService: PaywallRevAlertServiceUseCaseProtocol) {
        self.router = router
        self.apphudManager = apphudManager
        self.alertService = alertService
        _trialPriceRelay.rx.accept(apphudManager.getTrialPrice())
        _prodPriceRelay.rx.accept(apphudManager.getProdPrice())
        _paywallButtonTitleRelay.rx.accept(apphudManager.config.paywallButtonTitle)
        bind()
    }
    
    private func bind() {
        viewDidLoad
            .flatMapLatest { _ in
                Observable<Void>.just(())
                    .delay(
                        .seconds(
                            Int(self.apphudManager.config.paywallCloseDelay)),
                        scheduler: MainScheduler.instance)
            }
            .bind(to: _showCrossButton.rx)
            .disposed(by: bag)
        
        makePurchaseTapped
            .withLatestFrom(isTrialRelay)
            .subscribe(onNext: { [weak self] isTrial in
                guard let self else { return }
                apphudManager.makePurchase(isTrial: isTrial)
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
            .subscribe(onNext: { [weak self] _ in
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
extension PaywallRevVM {
    
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

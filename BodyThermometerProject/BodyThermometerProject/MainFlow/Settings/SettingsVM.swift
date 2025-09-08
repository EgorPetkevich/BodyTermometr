//
//  SettingsVM.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 24.08.25.
//

import Foundation
import RxSwift
import RxCocoa
import StoreKit

protocol SettingsRouterProtocol {
    func openNotificationSettings()
    func shareApp(url: URL)
    func openMail()
    func dismiss()
    func openPaywall()
}

final class SettingsVM: SettingsViewModelProtocol {
    
    // Out
    @Relay(value: [.contactUs,
                   .notification,
                   .rateThisApp,
                   .shareApp,
                   .privacyPolicy,
                   .termsOfUse])
    var items: Observable<[SettingsSection.Settings]>
    
    var isPremium: Driver<Bool> {
        UDManagerService.isPremiumDriver
    }
        
    // In
    var closeTapped: PublishSubject<Void> = .init()
    var upgradeButtonDidTap: PublishSubject<Void> = .init()
    
    private let isPremiumRelay = BehaviorRelay<Bool>(value: false)
    
    private let itemsRelay = BehaviorRelay<[SettingsSection.Settings]>(value: [
        .contactUs,
        .notification,
        .rateThisApp,
        .shareApp,
        .privacyPolicy,
        .termsOfUse
    ])
    
    private var router: SettingsRouterProtocol
    
    private var bag = DisposeBag()
    
    init(router: SettingsRouterProtocol) {
        self.router = router
        bind()
    }
    
    private func bind() {
        closeTapped.subscribe(onNext: { [weak self] in
            self?.router.dismiss()
        })
        .disposed(by: bag)
        upgradeButtonDidTap.subscribe(onNext: { [weak self] in
            self?.router.openPaywall()
        })
        .disposed(by: bag)
    }
    
    // In
    func didSelect(_ item: SettingsSection.Settings) {
        switch item {
        case .contactUs:
            router.openMail()
            break
        case .notification:
            router.openNotificationSettings()
            break
        case .rateThisApp:
            SKStoreReviewController.requestReviewInCurrentScene()
            break
        case .shareApp:
            if let url = URL(string: AppConfig.Settings.appLink) {
                router.shareApp(url: url)
            }
            break
        case .privacyPolicy:
            if let url = URL(string: AppConfig.Settings.privacyPolicyLink) {
                UIApplication.shared.open(url)
            }
            break
        case .termsOfUse:
            if let url = URL(string:  AppConfig.Settings.termsOfUseLink) {
                UIApplication.shared.open(url)
            }
            break
        }
    }
    
}

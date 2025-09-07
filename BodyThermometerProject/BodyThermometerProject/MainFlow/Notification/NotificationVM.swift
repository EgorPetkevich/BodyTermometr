//
//  NotificationVM.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 25.08.25.
//

import Foundation
import RxSwift
import RxCocoa
import UserNotifications

protocol NotificationRouterProtocol {
    func dismiss()
}

protocol NotificationAlertServiceUseCaseProtocol {
    func showError(title: String,
                   message: String,
                   goSettings: String,
                   goSettingsHandler: @escaping () -> Void,
                   cancelHandler: @escaping () -> Void)
}

final class NotificationVM: NotificationViewModelProtocol {
    // Out
    var notificationState: Driver<Bool> {
        UDManagerService.notificatonStateDriver
    }
    var switchState: Driver<Bool> { switchStateRelay.asDriver() }
    var isSwitchEnabled: Driver<Bool> { isSwitchEnabledRelay.asDriver().distinctUntilChanged() }
    // In
    var backButtonTapped: PublishRelay<Void> = .init()
    var viewWillAppear: PublishRelay<Void> = .init()
    var switchToggled: PublishRelay<Bool> = .init()
    
    private var router: NotificationRouterProtocol
    private let alertService: NotificationAlertServiceUseCaseProtocol
    
    private var bag = DisposeBag()
    
    private let switchStateRelay = BehaviorRelay<Bool>(value: false)
    private let isSwitchEnabledRelay = BehaviorRelay<Bool>(value: false)
    
    init(router: NotificationRouterProtocol,
         alertService: NotificationAlertServiceUseCaseProtocol) {
        self.router = router
        self.alertService = alertService
        bind()
    }
    
    private func refreshAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard let self else { return }
            let authorized = (settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional)
            if authorized {
                let udState = UDManagerService.get(.notificationState)
                self.isSwitchEnabledRelay.accept(true)
                self.switchStateRelay.accept(udState)
            } else {
                UDManagerService.setNotificatonState(false)
                self.isSwitchEnabledRelay.accept(true)
                self.switchStateRelay.accept(false)
            }
        }
    }
    
    private func bind() {
        backButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.router.dismiss()
            })
            .disposed(by: bag)
        
        viewWillAppear
            .subscribe(onNext: { [weak self] in
                self?.refreshAuthorization()
            })
            .disposed(by: bag)
        
        switchToggled
            .subscribe(onNext: { [weak self] isOn in
                guard let self else { return }
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    let authorized = (settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional)
                    if authorized {
                        UDManagerService.setNotificatonState(isOn)
                        self.switchStateRelay.accept(isOn)
                    } else {
                        // Immediately revert UI and UD, then show alert
                        DispatchQueue.main.async {
                            self.switchStateRelay.accept(false)
                            UDManagerService.setNotificatonState(false)
                            self.alertService.showError(
                                title: "Notifications are Off",
                                message: "Enable notifications in Settings to receive reminders.",
                                goSettings: "Open Settings",
                                goSettingsHandler: {
                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(url)
                                    }
                                },
                                cancelHandler: { [weak self] in
                                    guard let self = self else { return }
                                    DispatchQueue.main.async {
                                        self.switchStateRelay.accept(false)
                                        UDManagerService.setNotificatonState(false)
                                    }
                                    self.switchStateRelay.accept(false)
                                    UDManagerService.setNotificatonState(false)
                                }
                            )
                        }
                    }
                }
            })
            .disposed(by: bag)
    }
    
    
}

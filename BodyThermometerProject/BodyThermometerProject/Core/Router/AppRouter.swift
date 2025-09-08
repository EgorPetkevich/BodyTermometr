//
//  AppRouter.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 14.08.25.
//

import UIKit
import RxSwift
import RxCocoa

final class AppRouter {
    
    private let windowScene: UIWindowScene
    
    private var window: UIWindow?
    
    private let container: Container
    
    private var bag: DisposeBag = .init()
    
    private var isMainFlowVisible: Bool = false
    
    private let apphudManager: ApphudRxManager
    
    init(windowScene: UIWindowScene) {
        self.windowScene = windowScene
        self.container = ContainerConfigurator.make()
        self.apphudManager = container.resolve()
        container.lazyRegister({ WindowManager(scene: windowScene) })
       
        bindFlows()
        bindLifecycle()
    }
    
    func start() {
        window = UIWindow(windowScene: windowScene)
        window?.overrideUserInterfaceStyle = .light

        let initAndRoute = apphudManager.start()
            .andThen(apphudManager.hasActiveSubscription())
            .asObservable()
            .flatMap { [weak self] isActive -> Observable<Bool> in
                guard let self = self else { return .empty() }
                if isActive {
                    return .just(true)
                } else {
                    return self.apphudManager
                        .loadPaywall(
                            for:
                                UDManagerService
                                .isOnboardingShown() ? .inApp : .onboarding
                        )
                        .andThen(Observable.just(false))
                        .asObservable()
                }
            }
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] isActive in
                guard let self = self else { return }
                if isActive {
                    UDManagerService.setIsPremium(true)
                    UDManagerService.isOnboardingShown() ?
                    startMainOrRegistrationFlow() : startOnbordingFlow()
                    
                } else {
                    UDManagerService.setIsPremium(false)
                    UDManagerService.isOnboardingShown() ?
                    showAppPaywall() : startOnbordingFlow()
                }
            })

        initAndRoute.subscribe().disposed(by: bag)

    }
    
    private func startMainOrRegistrationFlow() {
        UDManagerService.isUserRegistrated() ?
         startMainFlow() : startRegistrationFlow()
    }
    
    private func setRoot(
        _ vc: UIViewController,
        animated: Bool = true
    ) {
        guard let window = window else { return }
        let changeRoot = { window.rootViewController = vc;
            window.makeKeyAndVisible() }
        
        guard animated else { changeRoot(); return }
        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: changeRoot,
                          completion: nil)
    }
    
    private func setupNotifications() {
        // Notifications
        let notifications: NotificationsServiceProtocol = container.resolve()
        notifications.configure()
        notifications.requestAuthorization()
            .subscribe(onSuccess: { granted in
                guard granted else { return }
                let times: [DateComponents] = [
                    DateComponents(hour: 9, minute: 41),
                    DateComponents(hour: 20, minute: 0)
                ]
                notifications.scheduleDailyReminders(times)
            })
            .disposed(by: bag)
    }
    
    
}

private extension AppRouter {
    func bindLifecycle() {
        NotificationCenter.default.rx
            .notification(UIApplication.willEnterForegroundNotification)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                guard self.isMainFlowVisible else { return }
                guard UDManagerService.isPremium() == false else { return }
                self.presentRevPaywall()
            })
            .disposed(by: bag)
    }
}

//MARK: - AppFlow
private extension AppRouter {
    
    private func bindFlows() {
        let flow: AppFlow = container.resolve()
        
        flow.didFinishOnboarding
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                apphudManager.loadPaywall(for: .inApp)
                UDManagerService.isPremium() ?
                startMainOrRegistrationFlow() : showOnbPaywall()
            })
            .disposed(by: bag)
        
        flow.didFinishPaywall
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                startMainOrRegistrationFlow()
            })
            .disposed(by: bag)
        
        flow.didFinishRegistration
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.startMainFlow()
            })
            .disposed(by: bag)
    }
    
}

//MARK: - Onbording
private extension AppRouter {
    
    func startOnbordingFlow() {
        isMainFlowVisible = false
        let vc = OnbFirstAssembler.assembly(container: container)
        let nc = UINavigationController(rootViewController: vc)
        setRoot(nc)
    }
    
}

//MARK: - Paywall
private extension AppRouter {
    
    func showAppPaywall() {
        isMainFlowVisible = false
        openRevPaywall()
    }
    
    func showOnbPaywall() {
        isMainFlowVisible = false
        apphudManager.isTrial() ? openProdTrialPaywall() : openProdPaywall()
    }
    
    func openProdTrialPaywall() {
        isMainFlowVisible = false
        let vc = PaywallProdTrialAssembler.assemble(container: container)
        setRoot(vc)
    }
    
    func openProdPaywall() {
        isMainFlowVisible = false
        let vc = PaywallProdAssembler.assemble(container: container)
        setRoot(vc)
    }
    
    func openRevPaywall() {
        isMainFlowVisible = false
        let vc = PaywallRevAssembler.assemble(container: container, true)
        setRoot(vc)
    }
    
    func presentRevPaywall() {
        let vc = PaywallRevAssembler.assemble(container: container)
        vc.modalPresentationStyle = .fullScreen
        window?.rootViewController?.present(vc, animated: true, completion: nil)
    }
    
}

//MARK: - Registration
private extension AppRouter {
    
    func startRegistrationFlow() {
        isMainFlowVisible = false
        let vc = RegUserInfoAssembler.assembly(container: container)
        let nc = UINavigationController(rootViewController: vc)
        setRoot(nc)
    }
    
}

//MARK: - Main
private extension AppRouter {
    
    func startMainFlow() {
        isMainFlowVisible = true
        setupNotifications()
        let vc = MainAssembler.assembly(container: container)
        let nc = UINavigationController(rootViewController: vc)
        setRoot(nc)
    }
    
}

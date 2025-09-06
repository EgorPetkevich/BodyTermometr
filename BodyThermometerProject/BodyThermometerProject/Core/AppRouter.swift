//
//  AppRouter.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 14.08.25.
//

import UIKit
import RxSwift

final class AppRouter {
    
    private let windowScene: UIWindowScene
    
    private var window: UIWindow?
    
    private let container: Container
    
    private var bag: DisposeBag = .init()
    
    init(windowScene: UIWindowScene) {
        self.windowScene = windowScene
        self.container = ContainerConfigurator.make()
        container.lazyRegister({ WindowManager(scene: windowScene) })
        bindFlows()
    }
    
    
    func start() {
        window = UIWindow(windowScene: windowScene)
        window?.overrideUserInterfaceStyle = .light
        UDManagerService.setIsPremium(false)
//        startOnbordingFlow()
        startMainFlow()
//        let vc = MeasuringResultAssembler.assembly(container: container, bpmResult: 40)
//        setRoot(vc)
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
    
    
}

//MARK: - AppFlow
private extension AppRouter {
    
    private func bindFlows() {
        let flow: AppFlow = container.resolve()
        
        flow.didFinishOnboarding
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.showPaywall()
            })
            .disposed(by: bag)
        
        flow.didFinishPaywall
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.startRegistrationFlow()
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
        let vc = OnbFirstAssembler.assembly(container: container)
        let nc = UINavigationController(rootViewController: vc)
        setRoot(nc)
    }
    
}

//MARK: - Paywall
private extension AppRouter {
    
    func showPaywall() {
        //Add config
        openRevPaywall()
    }
    
    func openProdTrialPaywall() {
        let vc = PaywallProdTrialAssembler.assemble(container: container)
        setRoot(vc)
    }
    
    func openProdPaywall() {
        let vc = PaywallProdAssembler.assemble(container: container)
        setRoot(vc)
    }
    
    func openRevPaywall() {
        let vc = PaywallRevAssembler.assemble(container: container)
        setRoot(vc)
    }
    
}

//MARK: - Registration
private extension AppRouter {
    
    func startRegistrationFlow() {
        let vc = RegUserInfoAssembler.assembly(container: container)
        let nc = UINavigationController(rootViewController: vc)
        setRoot(nc)
    }
    
}

//MARK: - Main
private extension AppRouter {
    
    func startMainFlow() {
        let vc = MainAssembler.assembly(container: container)
        let nc = UINavigationController(rootViewController: vc)
        setRoot(nc)
    }
    
}

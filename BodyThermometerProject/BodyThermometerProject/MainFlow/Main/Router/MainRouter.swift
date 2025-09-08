//
//  MainRouter.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 18.08.25.
//

import UIKit
import RxSwift

final class MainRouter: MainRouterProtocol {
    
    weak var root: UIViewController?
    
    private let container: Container
    private let bag = DisposeBag()
    
    init(container: Container) {
        self.container = container
    }
    
    func openProfile() {
        let vc = ProfileAssembler.assebly(container: container)
        vc.modalPresentationStyle = .fullScreen
        root?.present(vc, animated: true)
    }
    
    func openSettings() {
        let vc = SettingsAssembler.assembly(container: container)
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.custom { _ in return 663 }]
            sheet.prefersGrabberVisible = false
        }
        vc.modalPresentationStyle = .pageSheet

        root?.present(vc, animated: true)
    }
    
    func openHeartRate() {
        guard let root else { return }
        let vc = MeasuringAssembler.assembly(container: container)
        root.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openTemperatureInput() {
        guard let root else { return }
        let vc = TemperatureInputAssembler.assembly(container: container)
        root.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openStatistics() {
        guard let root else { return }
        let vc = StatisticsAssembler.assembly(container: container)
        root.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func presentAttentionIfNeeded() {
        guard UDManagerService.dontShowAgain == false else { return }
        let vc = AttentionAlertVC()
        vc.modalTransitionStyle = .crossDissolve
        vc.done
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { dontShow in
                UDManagerService.dontShowAgain = dontShow
            })
            .disposed(by: bag)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        root?.present(vc, animated: true, completion: nil)
    }
    
    func showPaywall() {
        let vc = PaywallRevAssembler.assemble(container: container)
        vc.modalPresentationStyle = .fullScreen
        root?.present(vc, animated: true)
    }
    
}

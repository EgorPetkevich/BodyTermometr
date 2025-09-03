//
//  MainRouter.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 18.08.25.
//

import UIKit

final class MainRouter: MainRouterProtocol {
    
    weak var root: UIViewController?
    
    private let container: Container
    
    init(container: Container) {
        self.container = container
    }
    
    func openProfile() {
        let vc = ProfileAssembler.assebly(container: container)
        vc.modalPresentationStyle = .fullScreen
        root?.present(vc, animated: true)
    }
    
    func openSettings() {
        let vc = SettingsAssembler.assembly()
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
    
}

//
//  StatisticsRouter.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 1.09.25.
//

import UIKit

final class StatisticsRouter: StatisticsRouterProtocol {
    
    weak var root: UIViewController?
    
    private let container: Container
    
    init(container: Container) {
        self.container = container
    }
    
    func openBPMDetails(with dto: BPMModelDTO) {
        let vc = BPMDetailsAssembler.assembly(container: container, dto: dto)
        let nc = UINavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .fullScreen
        root?.present(nc, animated: true)
    }
    
    func openTempDetails(with dto: TempModelDTO) {
        
    }
    
    func dismiss() {
        root?.navigationController?.popViewController(animated: true)
    }
    
}

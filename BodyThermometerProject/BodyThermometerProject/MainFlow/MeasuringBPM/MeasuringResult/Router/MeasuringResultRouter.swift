//
//  MeasuringResultRouter.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 27.08.25.
//

import UIKit

final class MeasuringResultRouter: MeasuringResultRouterProtocol {
    
    weak var root: UIViewController?
    
    private let container: Container
    
    init(container: Container) {
        self.container = container
    }
    
    func dismiss() {
        root?.navigationController?.popViewController(animated: true)
    }
    
    func openMain() {
        root?.navigationController?.popToRootViewController(animated: true)
    }
    
    func showPaywall() {
        let vc = PaywallRevAssembler.assemble(container: container)
        vc.modalPresentationStyle = .fullScreen
        root?.present(vc, animated: true)
    }
    
}

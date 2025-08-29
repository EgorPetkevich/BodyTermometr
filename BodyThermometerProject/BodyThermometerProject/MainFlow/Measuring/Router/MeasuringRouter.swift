//
//  MeasuringRouter.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 26.08.25.
//

import UIKit

final class MeasuringRouter: MeasuringRouterProtocol {
    
    weak var root: UIViewController?
    weak var measuringGuideVC: UIViewController?
    
    private var container: Container
    
    init(container: Container) {
        self.container = container
    }
    
    func openMeasuringGuide() {
        let vc = MeasuringGuideAssembler.assembly()
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.custom { _ in return 464 }]
            sheet.prefersGrabberVisible = false
        }
        vc.modalPresentationStyle = .pageSheet
        measuringGuideVC = vc
        root?.present(vc, animated: true)
    }
    
    func clouseMeasuringGuide() {
        measuringGuideVC?.dismiss(animated: true)
        measuringGuideVC = nil
    }
    
    func openMeasuringResule(_ result: Int) {
        let vc = MeasuringResultAssembler.assembly(container: container,
                                                   bpmResult: result)
        root?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func dismiss() {
        root?.dismiss(animated: true)
    }
    
}

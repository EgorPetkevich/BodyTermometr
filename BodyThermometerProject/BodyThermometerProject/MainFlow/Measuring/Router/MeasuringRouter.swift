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
    
    func dismiss() {
        root?.dismiss(animated: true)
    }
    
}

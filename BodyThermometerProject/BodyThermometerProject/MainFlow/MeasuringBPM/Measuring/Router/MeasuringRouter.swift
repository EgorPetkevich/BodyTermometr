//
//  MeasuringRouter.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 26.08.25.
//

import UIKit
import RxSwift

final class MeasuringRouter: MeasuringRouterProtocol {
    
    weak var root: UIViewController?
    weak var measuringGuideVC: UIViewController?
    
    private var container: Container
    private var subject: PublishSubject<Int>?
    
    init(container: Container, subject: PublishSubject<Int>? = nil) {
        self.container = container
        self.subject = subject
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
        guard let subject else {
            let vc = MeasuringResultAssembler.assembly(container: container,
                                                       bpmResult: result)
            root?.navigationController?.pushViewController(vc, animated: true)
            return
        }
        subject.onNext(result)
        root?.navigationController?.popViewController(animated: true)
       
    }
    
    func dismiss() {
        root?.navigationController?.popToRootViewController(animated: true)
    }
    
}

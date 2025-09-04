//
//  BPMDetailsRouter.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 4.09.25.
//

import UIKit
import RxSwift

final class BPMDetailsRouter: BPMDetailsRouterProtocol {
    
    weak var root: UIViewController?
    
    private let container: Container
    
    init(container: Container) {
        self.container = container
    }
    
    func openEdit(with subject: PublishSubject<Int>) {
        let vc = MeasuringAssembler.assembly(container: container,
                                             subject: subject)
        root?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func dismiss() {
        root?.dismiss(animated: true)
    }
    
}

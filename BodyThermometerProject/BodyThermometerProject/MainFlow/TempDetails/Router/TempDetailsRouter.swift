//
//  TempDetailsRouter.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 4.09.25.
//

import UIKit
import RxSwift
import RxCocoa

final class TempDetailsRouter: TempDetailsRouterProtocol {

    private let container: Container
    
    weak var root: UIViewController?
    
    init(container: Container) {
        self.container = container
    }
    
    func openEdit(with dto: TempModelDTO) {
        let vc = TemperatureInputAssembler.assembly(container: container, dto)
        root?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func dismiss() {
        root?.dismiss(animated: true)
    }
    
}

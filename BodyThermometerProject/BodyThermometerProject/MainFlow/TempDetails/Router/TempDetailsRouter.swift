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
    
    var deleteTapped = PublishRelay<Void>()
    
    private var bag = DisposeBag()
    
    init(container: Container) {
        self.container = container
    }
    
    func openEdit(with dto: TempModelDTO) {
        let vc = TemperatureInputAssembler.assembly(container: container, dto)
        root?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func dismiss() {
        DispatchQueue.main.async { [weak self] in
            guard let root = self?.root else { return }
            func close(_ vc: UIViewController) {
                if let presented = vc.presentedViewController {
                    presented.dismiss(animated: true) { close(vc) }
                    return
                }
               
                if vc.presentingViewController != nil {
                    vc.dismiss(animated: true, completion: nil)
                    return
                }
                vc.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            }
            close(root)
        }
    }
    
    func presentDeleteEntry() {
        let vc = DeleteEntryVC()
        vc.deleteTapped
            .bind(to: deleteTapped)
            .disposed(by: bag)
        
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        
        root?.present(vc, animated: true, completion: nil)
    }
    
    
}

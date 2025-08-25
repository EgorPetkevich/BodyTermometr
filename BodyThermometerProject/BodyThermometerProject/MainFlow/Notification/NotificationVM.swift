//
//  NotificationVM.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 25.08.25.
//

import Foundation
import RxSwift
import RxCocoa

protocol NotificationRouterProtocol {
    func dismiss()
}

final class NotificationVM: NotificationViewModelProtocol {
    //Out
    var notificationState: Driver<Bool> {
        UDManagerService.notificatonStateDriver
    }
    //In
    var backButtonTapped: PublishRelay<Void> = .init()
    
    private var router: NotificationRouterProtocol
    
    private var bag = DisposeBag()
    
    init(router: NotificationRouterProtocol) {
        self.router = router
        bind()
    }
    
    private func bind() {
        backButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.router.dismiss()
            })
            .disposed(by: bag)
    }
    
    
}

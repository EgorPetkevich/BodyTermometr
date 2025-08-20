//
//  PaywallRevVM.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 15.08.25.
//

import UIKit
import RxSwift

protocol PaywallRevRouterProtocol {
    func finish()
}

final class PaywallRevVM: PaywallRevViewModelProtocol {
    //Out
    @Subject()
    var showCrossButton: Observable<Void>
    //In
    var crossTapped: PublishSubject<Void> = .init()
    var viewDidLoad: PublishSubject<Void> = .init()
    var didSelectPrivacy: PublishSubject<Void> = .init()
    var didSelectRestore: PublishSubject<Void> = .init()
    var didSelectTerms: PublishSubject<Void> = .init()
    
    
    private let router: PaywallRevRouterProtocol
    
    private var bag = DisposeBag()
    
    init(router: PaywallRevRouterProtocol) {
        self.router = router
        bind()
    }
    
    private func bind() {
        viewDidLoad
            .flatMapLatest { _ in
                Observable<Void>.just(())
                    .delay(.seconds(3), scheduler: MainScheduler.instance)
            }
            .bind(to: _showCrossButton.rx)
            .disposed(by: bag)
        
        crossTapped
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.router.finish()
            })
            .disposed(by: bag)
        
        didSelectTerms.subscribe(onNext: { [weak self] _ in
            print("Terms did Select")
        })
        .disposed(by: bag)
        
        didSelectPrivacy.subscribe(onNext: { [weak self] _ in
            print("Priavcy did Select")
        })
        .disposed(by: bag)
        
        didSelectRestore.subscribe(onNext: { [weak self] _ in
            print("Restore did Select")
        })
        .disposed(by: bag)
            
    }
    
}


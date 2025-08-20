//
//  PaywallProdTrialVM.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 14.08.25.
//

import UIKit
import RxSwift

protocol PaywallProdTrialRouterProtocol {
    func finish()
}

final class PaywallProdTrialVM: PaywallProdTrialViewModelProtocol {
    //Out
    @Subject()
    var showCrossButton: Observable<Void>
    //In
    var crossTapped: PublishSubject<Void> = .init()
    var viewDidLoad: PublishSubject<Void> = .init()
    var didSelectPrivacy: PublishSubject<Void> = .init()
    var didSelectRestore: PublishSubject<Void> = .init()
    var didSelectTerms: PublishSubject<Void> = .init()
    
    
    private let router: PaywallProdTrialRouterProtocol
    
    private var bag = DisposeBag()
    
    init(router: PaywallProdTrialRouterProtocol) {
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
            .subscribe(onNext: { [weak self] in
                self?.router.finish()
            })
            .disposed(by: bag)
        
        didSelectTerms.subscribe { [weak self] _ in
            print("Terms did Select")
        }
        .disposed(by: bag)
        
        didSelectPrivacy.subscribe { [weak self] _ in
            print("Priavcy did Select")
        }
        .disposed(by: bag)
        
        didSelectRestore.subscribe { [weak self] _ in
            print("Restore did Select")
        }
        .disposed(by: bag)
            
    }
    
}

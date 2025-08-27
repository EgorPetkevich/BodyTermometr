//
//  MeasuringGuideVM.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 26.08.25.
//

import Foundation
import RxSwift
import RxCocoa

protocol MeasuringGuideRouterProtocol {
    func dismiss()
}

final class MeasuringGuideVM: MeasuringGuideViewModelProtocol {
    
    @Subject(value: false)
    var checkBoxState: Observable<Bool>
    
    var checkBoxTapped: PublishSubject<Void> = .init()
    
    var clouseButtonTapped: PublishSubject<Void> = .init()
    
    private let router: MeasuringGuideRouterProtocol
    
    private var bag = DisposeBag()
    
    init(router: MeasuringGuideRouterProtocol) {
        self.router = router
        bind()
    }
    
    func bind() {
        clouseButtonTapped
            .withLatestFrom(checkBoxState)
            .subscribe(onNext: { [weak self] state in
                self?.saveCheckBoxState(!state)
                self?.router.dismiss()
            })
        .disposed(by: bag)
        
        checkBoxTapped
            .withLatestFrom(checkBoxState)
            .map { !$0 }
            .bind(to: _checkBoxState.rx)
            .disposed(by: bag)
    }
    
    private func saveCheckBoxState(_ state: Bool) {
        UDManagerService.setMeasuringGuideEnabled(state)
    }
    
}

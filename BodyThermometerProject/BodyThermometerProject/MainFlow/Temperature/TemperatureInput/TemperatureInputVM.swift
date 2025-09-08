//
//  TemperatureInputVM.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 30.08.25.
//

import Foundation
import RxSwift
import RxCocoa

protocol TemperatureInputRouterProtocol {
    func openTempCondition(temperature: Double, unit: TempUnit)
    func dismiss()
}

protocol TemperatureInputKeyBoardHelperServiceUseCaseProtocol {
    var frame: Observable<CGRect> { get }
}

final class TemperatureInputVM: TemperatureInputViewModelProtocol {
    //Out
    @Subject()
    var keyBoardFrame: Observable<CGRect>
    // Out
    var crossButtonTapped = PublishRelay<Void>()
    var continuButtonTapped = PublishRelay<Void>()
    var temperatureSubject = BehaviorSubject<Double?>(value: nil)
    var temperatureUnitSubject = BehaviorSubject<TempUnit?>(value: nil)
    
    private var router: TemperatureInputRouterProtocol
    private var keyboardHelper: TemperatureInputKeyBoardHelperServiceUseCaseProtocol
    
    private var bag = DisposeBag()
    
    init(router: TemperatureInputRouterProtocol,
         keyboardHelper: TemperatureInputKeyBoardHelperServiceUseCaseProtocol) {
        self.router = router
        self.keyboardHelper = keyboardHelper
        bind()
    }
    
    private func bind() {
        keyboardHelper
            .frame
            .bind(to: _keyBoardFrame.rx)
            .disposed(by: bag)
        
        crossButtonTapped.subscribe(onNext: { [weak self] in
            self?.router.dismiss()
        })
        .disposed(by: bag)
        
        let latestInputs = Observable
            .combineLatest(
                temperatureSubject.compactMap { $0 },
                temperatureUnitSubject.compactMap { $0 }
            )

        continuButtonTapped
            .withLatestFrom(latestInputs)
            .subscribe(onNext: { [weak self] temp, unit in
                guard let self,
                      isValidTemperature(temp, for: unit)
                else { return }
                UDManagerService.setIsFirstTempMeasurement(true)
                router.openTempCondition(temperature: temp, unit: unit)
            })
            .disposed(by: bag)
    }
    
    private func isValidTemperature(
        _ value: Double,
        for unit: TempUnit
    ) -> Bool {
        switch unit {
        case .c:
            return value >= 30 && value <= 45
        case .f:
            return value >= 86 && value <= 113
        }
    }
    
    
}

//
//  TempConditionRouter.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 30.08.25.
//

import UIKit
import RxSwift

final class TempConditionRouter: TempConditionRouterProtocol {
    
    @Subject()
    var selectedDate: Observable<Date>
    @Subject()
    var selectedTime: Observable<Date>
    
    weak var root: UIViewController?
    
    private let container: Container
    
    private var bag = DisposeBag()
    
    init(container: Container) {
        self.container = container
    }
    
    func dismiss() {
        root?.navigationController?.popViewController(animated: true)
    }
    
    func openMain() {
        root?.navigationController?.popToRootViewController(animated: true)
    }
    
    func openDatePicker() {
        let vc = DatePickerVC(initial: Date(),
                                  type: .date,
                                  minimumDate: nil,
                                  maximumDate: Date())
        vc.selectedDate
            .bind(to: _selectedDate.rx)
            .disposed(by: bag)
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.custom { _ in return 401 }]
            sheet.prefersGrabberVisible = false
        }
        vc.modalPresentationStyle = .pageSheet
        root?.present(vc, animated: true)
    }
    
    func openTimePicker() {
        let vc = DatePickerVC(initial: Date(), type: .time)
        vc.selectedDate
            .bind(to: _selectedTime.rx)
            .disposed(by: bag)
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.custom { _ in return 401 }]
            sheet.prefersGrabberVisible = false
        }
        vc.modalPresentationStyle = .pageSheet
        root?.present(vc, animated: true)
        
    }
    
}



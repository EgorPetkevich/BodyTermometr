//
//  AlertManagerService.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 4.09.25.
//

import UIKit
import RxSwift
import RxCocoa

final class AlertManagerService: NSObject {
    
    enum SheetChoice {
        case first, second, cancel
    }
    
    private let windowManager: WindowManager
    
    init(container: Container) {
        self.windowManager = container.resolve() 
        
    }
    
    func actionSheetRx(
        title: String? = nil,
        message: String? = nil,
        firstTitle: String,
        secondTitle: String,
        cancelTitle: String = "Cancel"
    ) -> Single<SheetChoice> {

           return Single.create { [weak self] observer in
               guard let self else { return Disposables.create() }

               let alertVC = UIAlertController(title: title,
                                               message: message,
                                               preferredStyle: .actionSheet)

               alertVC.addAction(
                UIAlertAction(title: firstTitle,
                              style: .default) { [weak self] _ in
                   observer(.success(.first))
                   self?.windowManager.hideAndRemove(type: .alert)
               })

               alertVC.addAction(
                UIAlertAction(title: secondTitle,
                              style: .destructive) { [weak self] _ in
                   observer(.success(.second))
                   self?.windowManager.hideAndRemove(type: .alert)
               })

               alertVC.addAction(
                UIAlertAction(title: cancelTitle,
                              style: .cancel) { [weak self] _ in
                   observer(.success(.cancel))
                   self?.windowManager.hideAndRemove(type: .alert)
               })


               let window = self.windowManager.get(type: .alert)
               window.rootViewController = UIViewController()
               self.windowManager.show(type: .alert)
               window.rootViewController?.present(alertVC, animated: true)

               return Disposables.create { [weak self] in
                   self?.windowManager.hideAndRemove(type: .alert)
               }
           }
           .observe(on: MainScheduler.instance)
       }
    
}

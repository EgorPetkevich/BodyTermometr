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
    
    typealias ActionHandler = (_ text: String?) -> Void
    typealias AlertActionHandler = () -> Void
    
    enum SheetChoice {
        case first, second, cancel
    }
    
    
    private let windowManager: WindowManager
    
    
    init(container: Container) {
        self.windowManager = container.resolve() 
        
    }
    
    func showAlert(title: String?,
                   message: String? = nil,
                   cancelTitle: String? = nil,
                   cancelHandler: AlertActionHandler? = nil,
                   okTitle: String? = nil,
                   okHandler: AlertActionHandler? = nil,
                   settingTitle: String? = nil,
                   settingHandler: AlertActionHandler? = nil
    ) {
        //Build
        let alertVC = buildAlert(title: title,
                                 message: message,
                                 cancelTitle: cancelTitle,
                                 cancelHandler: cancelHandler,
                                 okTitle: okTitle,
                                 okHandler: okHandler,
                                 settingTitle: settingTitle,
                                 settingHandler: settingHandler)
        
        let window = windowManager.get(type: .alert)
        window.rootViewController = UIViewController()
        windowManager.show(type: .alert)
        window.rootViewController?.present(alertVC, animated: true)
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

//MARK: - Private
private extension AlertManagerService {
    
    
    private func buildAlert(title: String?,
                            message: String?,
                            cancelTitle: String? = nil,
                            cancelHandler: AlertActionHandler? = nil,
                            okTitle: String? = nil,
                            okHandler: AlertActionHandler? = nil,
                            settingTitle: String? = nil,
                            settingHandler: AlertActionHandler? = nil
                            
    ) -> UIAlertController {
        let alertVC = UIAlertController(title: title,
                                        message: message,
                                        preferredStyle: .alert)
        
        if let cancelTitle {
            let action = UIAlertAction(title: cancelTitle,
                                       style: .cancel) { [weak self] _ in
                cancelHandler?()
                self?.windowManager.hideAndRemove(type: .alert)
            }
            alertVC.addAction(action)
        }
        
        if let okTitle {
            let action = UIAlertAction(title: okTitle,
                                       style: .default) { [weak self] _ in
                okHandler?()
                self?.windowManager.hideAndRemove(type: .alert)
            }
            alertVC.addAction(action)
        }
        
        if let settingTitle {
            let action = UIAlertAction(title: settingTitle,
                                       style: .default) { [weak self] _ in
                settingHandler?()
                self?.windowManager.hideAndRemove(type: .alert)
            }
            alertVC.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel) { [weak self] _ in
                cancelHandler?()
                self?.windowManager.hideAndRemove(type: .alert)
            })
            alertVC.addAction(action)
        }
        
        return alertVC
    }
    
    
}

//
//  SettingsRouter.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 24.08.25.
//

import UIKit

final class SettingsRouter: SettingsRouterProtocol {
    
    weak var root: UIViewController?
    
    func openMail() {
        guard
            let root,
            let mailVC = MailAssembler.assembly(rootVC: root)
        else { return }
        root.present(mailVC, animated: true)
       
    }
    
    func openNotificationSettings() {
        let vc = NotificationAssembler.assembly()
        vc.modalPresentationStyle = .fullScreen
        root?.present(vc, animated: true)
    }
    
    func dismiss() {
        root?.dismiss(animated: true)
    }
    
}

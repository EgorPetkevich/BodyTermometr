//
//  MailAssembler.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 25.08.25.
//

import UIKit
import MessageUI

final class MailAssembler {
    
    private init() {}
    
    static func assembly(rootVC: UIViewController) -> MailVC? {
        if MFMailComposeViewController.canSendMail() {
            let mail = MailVC()
            mail.configureMailView(
                recipients: [AppConfig.Settings.contactEmail],
                subject: "Body Thermometer Helper",
                body: "Hello, I need assistance with your application.",
                from: rootVC
            )
            return mail
        }
        return nil
    }
}

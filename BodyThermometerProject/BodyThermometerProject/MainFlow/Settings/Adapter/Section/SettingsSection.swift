//
//  SettingsSection.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 25.08.25.
//

import UIKit

final class SettingsSection {
    
    enum Settings: SettingsRowProtocol {
        case contactUs
        case notification
        case rateThisApp
        case shareApp
        case privacyPolicy
        case termsOfUse
        
        var titleText: String {
            switch self {
            case .contactUs: "Contact us"
            case .notification: "Notification"
            case .rateThisApp: "Rate this app"
            case .shareApp: "Share App"
            case .privacyPolicy: "Privacy Policy"
            case .termsOfUse: "Terms of use"
            }
        }
        
        var iconImage: UIImage {
            switch self {
            case .contactUs: .settingsContact
            case .notification: .settingsNotification
            case .rateThisApp: .settingsTrophy
            case .shareApp: .settingsSend
            case .privacyPolicy: .settingsSecuritysafe
            case .termsOfUse: .settingsDocument
            }
        }
        
    }
    
    
    
}

//
//  UDManagerService.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 21.08.25.
//

import Foundation
import RxSwift
import RxCocoa



final class UDManagerService {
    
    enum Keys: String {
        case isPremium
        case createImageDirectory
        case notificationState
        case measuringGuideState
        case timer
        case attentionConsentDontShow
    }
    
    private static var ud: UserDefaults = .standard
    private static let isPremiumRelay = BehaviorRelay<Bool>(value: UDManagerService.get(.isPremium))
    private static let notificationStateRelay = BehaviorRelay<Bool>(value: UDManagerService.get(.notificationState))
    private static let measuringGuideStateRelay = BehaviorRelay<Bool>(value: UDManagerService.getMesuringGuideState())
    private static let attentionConsentRelay = BehaviorRelay<Bool>(value: UDManagerService.get(.attentionConsentDontShow))
    
    
    private init() {}
    
    static func set(_ key: Keys, value: Bool) {
        ud.setValue(value, forKey: key.rawValue)
    }
    
    static func get(_ key: Keys) -> Bool {
        ud.bool(forKey: key.rawValue)
    }
    
    static func getMesuringGuideState() -> Bool {
        if UserDefaults.standard.object(forKey: Keys.measuringGuideState.rawValue) == nil {
            UserDefaults.standard.setValue(true, forKey: Keys.measuringGuideState.rawValue)
            return true
        } else {
            return UDManagerService.get(.measuringGuideState)
        }
    }
    
}

// Attention Consent
extension UDManagerService {
    
    static var attentionConsentObservable: Observable<Bool> {
        attentionConsentRelay
            .asObservable()
            .distinctUntilChanged()
    }
    
    static var attentionConsentDriver: Driver<Bool> {
        attentionConsentRelay
            .asDriver()
            .distinctUntilChanged()
    }
    
    static func setAttentionConsentDontShow(_ value: Bool) {
        UDManagerService.set(.attentionConsentDontShow, value: value)
        if attentionConsentRelay.value != value {
            attentionConsentRelay.accept(value)
        }
    }
    
    static var dontShowAgain: Bool {
        get { get(.attentionConsentDontShow) }
        set { setAttentionConsentDontShow(newValue) }
    }
}

// Timer
extension UDManagerService {
    
    static func setTimer(_ timer: Int) {
        ud.set(timer, forKey: Keys.timer.rawValue)
    }
    
    static func getTimer() -> Int {
        if let value = ud.value(forKey: Keys.timer.rawValue) as? Int {
            return value
        }
        return 0
    }
    
}

// Subscription Status (Reactive)
extension UDManagerService {
    
    static var isPremiumObservable: Observable<Bool> {
        isPremiumRelay
            .asObservable()
            .distinctUntilChanged()
    }
    
    static var isPremiumDriver: Driver<Bool> {
        isPremiumRelay
            .asDriver()
            .distinctUntilChanged()
    }

    static func setIsPremium(_ value: Bool) {
        UDManagerService.set(.isPremium, value: value)
        if isPremiumRelay.value != value { isPremiumRelay.accept(value) }
    }
}

// Subscription Status (Notificatoin)
extension UDManagerService {
    
    static var notificatonStateObservable: Observable<Bool> {
        notificationStateRelay
            .asObservable()
            .distinctUntilChanged()
    }
    
    static var notificatonStateDriver: Driver<Bool> {
        notificationStateRelay
            .asDriver()
            .distinctUntilChanged()
    }

    static func setNotificatonState(_ value: Bool) {
        UDManagerService.set(.notificationState, value: value)
        if notificationStateRelay.value !=
            value { notificationStateRelay.accept(value) }
    }
}

// Subscription Status (Measuring Guide)
extension UDManagerService {
    
    static var measuringGuideObservable: Observable<Bool> {
        measuringGuideStateRelay
            .asObservable()
            .distinctUntilChanged()
    }
    static var measuringGuideDriver: Driver<Bool> {
        measuringGuideStateRelay
            .asDriver()
            .distinctUntilChanged()
    }

    static func setMeasuringGuideEnabled(_ value: Bool) {
        UDManagerService.set(.measuringGuideState, value: value)
        if measuringGuideStateRelay.value != value {
            measuringGuideStateRelay.accept(value)
        }
    }
}

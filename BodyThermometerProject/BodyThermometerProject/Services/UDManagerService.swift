//
//  UDManagerService.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 21.08.25.
//

import Foundation

final class UDManagerService {
    
    enum Keys: String {
        case createImageDirectory
        case timer
    }
    
    private static var ud: UserDefaults = .standard
    
    private init() {}
    
    static func set(_ key: Keys, value: Bool) {
        ud.setValue(value, forKey: key.rawValue)
    }
    
    static func get(_ key: Keys) -> Bool {
        ud.bool(forKey: key.rawValue)
    }
    
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


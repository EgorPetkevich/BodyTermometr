//
//  Date+DisplayString.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 2.09.25.
//

import Foundation

extension Date {
    func toDisplayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy  hh:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
}

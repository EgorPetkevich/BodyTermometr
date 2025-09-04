//
//  UserInfoModel.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 18.08.25.
//

import Foundation
import RealmSwift

final class UserInfoModel: Object {
    @Persisted(primaryKey: true) var id: String = "current"   
    @Persisted var userName: String = ""
    @Persisted var userAge: String = ""
    @Persisted var gender: Gender?
    @Persisted var iconPath: String = UserIconPath.path.rawValue
}

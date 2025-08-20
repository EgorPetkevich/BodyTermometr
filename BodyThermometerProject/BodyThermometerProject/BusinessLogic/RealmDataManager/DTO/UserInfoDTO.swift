//
//  UserInfoDTO.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 18.08.25.
//

import Foundation

struct UserInfoDTO: Equatable {
    var id: String = "current"
    var userName: String = ""
    var userAge: String = ""
    var gender: Gender?
    
    init(_ m: UserInfoModel) {
        id = "current"
        userName = m.userName
        userAge = m.userAge
        gender = m.gender
    }
}

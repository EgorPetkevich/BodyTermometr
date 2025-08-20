//
//  RealmDataManager+RegGender.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 18.08.25.
//

import Foundation

struct RegGenderRealDataManagerUseCase:
    RegGenderRealDataManagerUseCaseProtocol {
    
    private var realmDataManager: RealmDataManager
    
    init(realmDataManager: RealmDataManager) {
        self.realmDataManager = realmDataManager
    }
    
    func saveGender(_ gender: Gender) {
        realmDataManager.updateGender(gender)
    }
    
    
}


//
//  Realm+TempDetails.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 5.09.25.
//

import Foundation
import RxSwift

struct TempDetailsRealmBPMManagerUseCase:
    TempDetailsRealmDataManagerUseCaseProtocol {
    
    private let tempRealmManager: RealmTempManager
    
    init(tempRealmManager: RealmTempManager) {
        self.tempRealmManager = tempRealmManager
    }
    
    func deleteDTO(_ dto: TempModelDTO) {
        tempRealmManager.delete(dto: dto)
    }
    
    func updateDTO(_ dto: TempModelDTO) {
        tempRealmManager.createOrUpdate(dto: dto)
    }
    
    func observeTempModel(by id: String) -> Observable<TempModelDTO?> {
        tempRealmManager.observeTempModel(by: id)
    }
    
}

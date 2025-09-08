//
//  ApphudManager+OnbFirst.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 8.09.25.
//

import Foundation

struct OnbFirstApphudManagerUseCase: OnbFirstApphudManagerUseCaseProtocol {
    
    var config: RemoteConfig
    
    private let apphudService: ApphudRxManager
    
    init(apphudService: ApphudRxManager) {
        self.apphudService = apphudService
        self.config = apphudService.configRelay.value
    }
    
}

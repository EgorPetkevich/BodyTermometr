//
//  ApphudManager+OnbThird.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 8.09.25.
//

struct OnbThirdApphudManagerUseCase: OnbThirdApphudManagerUseCaseProtocol {
    
    var config: RemoteConfig
    
    private let apphudService: ApphudRxManager
    
    init(apphudService: ApphudRxManager) {
        self.apphudService = apphudService
        self.config = apphudService.configRelay.value
    }
    
}

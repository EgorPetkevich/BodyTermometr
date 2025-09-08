//
//  ContainerConfigurator.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 29.06.25.
//

import Foundation

final class ContainerConfigurator {
    private init() {}
    
    static func make() -> Container {
        let container = Container()
        
        container.lazyRegister { AppFlow() }
        container.lazyRegister { RealmDataManager() }
        container.lazyRegister { KeyboardHelperService() }
        container.lazyRegister { FileManagerService() }
        container.lazyRegister { RealmDataManager() }
        container.lazyRegister { RealmBPMManager() }
        container.lazyRegister { RealmTempManager() }
        container.lazyRegister { NotificationsService() as NotificationsServiceProtocol }
        container.lazyRegister { ApphudRxManager.instanse }
        
        return container
    }
}

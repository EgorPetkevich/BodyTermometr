//
//  StatisticsAssembler.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 1.09.25.
//

import UIKit

final class StatisticsAssembler {
    
    private init() {}
    
    static func assembly(container: Container) -> UIViewController {
        let router = StatisticsRouter(container: container)
        
        let tempRealm =
        StatisticsTempRealmManagerUseCase(realmManager: container.resolve())
        let bpmRealm =
        StatisticsBPMRealmManagerUseCase(realmManager: container.resolve())
        
        let viewModel = StatisticsVM(chart: StatChartView(),
                                     router: router,
                                     historyTableView: HistoryTableView(),
                                     intGuideTableView: IntGuideTableView(),
                                     tempRealmManager: tempRealm,
                                     bpmRealmManager: bpmRealm)
        let viewController = StatisticsVC(viewModel: viewModel)
        
        router.root = viewController
        return viewController
        
    }
    
}


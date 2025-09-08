//
//  StatisticsVM.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 1.09.25.
//

import Foundation
import DGCharts
import RxSwift
import RxCocoa
import RealmSwift

protocol StatisticsRouterProtocol {
    func dismiss()
    func openBPMDetails(with dto: BPMModelDTO)
    func openTempDetails(with dto: TempModelDTO, unit: TempUnit)
    func showPaywall()
}

protocol StatisticsTempRealmManagerUseCaseProtocol {
    func observeAllSortedByDate() -> Observable<[TempModelDTO]?>
}
protocol StatisticsBPMRealmManagerUseCaseProtocol {
    func observeAllSortedByDate() -> Observable<[BPMModelDTO]?>
}

final class StatisticsVM: StatisticsViewModelProtocol {
    //Out
    @Relay(value: Period.day)
    var setDayPeriodRelay: Observable<Period>
    // In
    var crossButtonTapped = PublishRelay<Void>()
    var tempUnitState = BehaviorRelay<TempUnit>(value: TempUnit.c)
    var modeSelected = BehaviorRelay<StatMode>(value: StatMode.temperature)
    var periodSelected = BehaviorRelay<Period>(value: Period.day)
    
    private var tempDTOSubject = BehaviorSubject<[TempModelDTO]?>(value: nil)
    private var bpmDTOSubject = BehaviorSubject<[BPMModelDTO]?>(value: nil)
   
    private var chart: StatChartViewProtocol
    private let router: StatisticsRouterProtocol
    private var historyTableView: HistoryTableViewTableViewProtocol
    private var intGuideTableView: IntGuideTableViewProtocol
    
    private let tempRealmManager: StatisticsTempRealmManagerUseCaseProtocol
    private let bpmRealmManager: StatisticsBPMRealmManagerUseCaseProtocol
    
    private var bag = DisposeBag()
    
    init(chart: StatChartViewProtocol,
         router: StatisticsRouterProtocol,
         historyTableView: HistoryTableViewTableViewProtocol,
         intGuideTableView: IntGuideTableViewProtocol,
         tempRealmManager: StatisticsTempRealmManagerUseCaseProtocol,
         bpmRealmManager: StatisticsBPMRealmManagerUseCaseProtocol) {
        self.chart = chart
        self.router = router
        self.historyTableView = historyTableView
        self.intGuideTableView = intGuideTableView
        self.tempRealmManager = tempRealmManager
        self.bpmRealmManager = bpmRealmManager
       
        bind()
    }
    
    private func bind() {
        bindRealm()
        bindButtons()
        bindChart()
        bindMode()
        bindHistoryTable()
    }
    
    private func bindButtons() {
        crossButtonTapped.subscribe(onNext: {[weak self] in
            self?.router.dismiss()
        }).disposed(by: bag)
            
    }
    
    private func bindHistoryTable() {
        historyTableView.bpmSelected
            .subscribe(onNext: { [weak self]  dto in
                self?.router.openBPMDetails(with: dto)
            })
            .disposed(by: bag)
        historyTableView.tempSelected
            .withLatestFrom(tempUnitState)  { dto, unit in (dto, unit) }
            .subscribe(onNext: { [weak self]  dto, unit in
                self?.router.openTempDetails(with: dto, unit: unit)
            })
            .disposed(by: bag)
    }
    
    private func bindMode() {
        tempUnitState
            .bind(to: chart.selectedUnit)
            .disposed(by: bag)
        tempUnitState
            .bind(to: historyTableView.currentUnitRelay)
            .disposed(by: bag)
        tempUnitState
            .bind(to: intGuideTableView.currentUnitRelay)
            .disposed(by: bag)
        
        periodSelected
            .subscribe(onNext: { [weak self] period in
                if UDManagerService.isPremium() {
                    self?.chart.set(period: period)
                    if let mode = self?.modeSelected.value {
                        switch mode {
                        case .temperature: self?.setupTempChart()
                        case .heartRate:  self?.setupBpmChart()
                        }
                    }
                } else {
                    switch period {
                    case .day:
                        if let mode = self?.modeSelected.value {
                            switch mode {
                            case .temperature: self?.setupTempChart()
                            case .heartRate:  self?.setupBpmChart()
                            }
                        }
                    case .week:
                        self?._setDayPeriodRelay.rx.accept(.day)
                        self?.router.showPaywall()
                    case .month:
                        self?._setDayPeriodRelay.rx.accept(.day)
                        self?.router.showPaywall()
                    }
                }
            })
            .disposed(by: bag)
        
        modeSelected.subscribe(onNext: { [weak self] mode in
            switch mode {
            case .temperature:
                self?.setupTempChart()
                self?.intGuideTableView
                        .setTempItems(IntGuideTempSection.IntGuideTemp.allCases)
            case .heartRate:
                self?.setupBpmChart()
                self?.intGuideTableView
                        .setBpmItems(IntGuideBpmSection.IntGuideBpm.allCases)
            }
        })
        .disposed(by: bag)
        
    }
    
    private func bindRealm() {
        tempRealmManager
            .observeAllSortedByDate()
            .bind(to: tempDTOSubject)
            .disposed(by: bag)
        bpmRealmManager
            .observeAllSortedByDate()
            .bind(to: bpmDTOSubject)
            .disposed(by: bag)
    }
    
    private func bindChart() {
        
        // Rebuild TEMP when either temp data or period changes and mode is temperature
        Observable.combineLatest(tempDTOSubject.asObservable(),
                                 periodSelected.asObservable())
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _, _ in
                guard self?.modeSelected.value == .temperature else { return }
                self?.setupTempChart()
            })
            .disposed(by: bag)

        // Rebuild BPM when either bpm data or period changes and mode is heartRate
        Observable.combineLatest(bpmDTOSubject.asObservable(), periodSelected.asObservable())
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _, _ in
                guard self?.modeSelected.value == .heartRate else { return }
                self?.setupBpmChart()
            })
            .disposed(by: bag)
    }
    
    func getChartView() -> ScatterChartView {
        chart.getChart()
    }
    
    func getHistoryTableViewView() -> UITableView {
        historyTableView.getTable()
    }
    
    func getIntGuideTableView() -> UITableView {
        intGuideTableView.getTable()
    }
    
}

//MARK: - Private
private extension StatisticsVM {
    
    func setupTempChart() {
        let per = periodSelected.value
        guard let items = try? tempDTOSubject.value() else {
            
            chart.set(points: [TempPoint](), for: per)
            historyTableView.setTempItems([])
            return
        }
       
        let filtered = filter(items, by: per, date: \TempModelDTO.date)
        let points = mapTempPoints(filtered)
        chart.set(points: points, for: per)
        historyTableView.setTempItems(items)
    }

    func setupBpmChart() {
        let per = periodSelected.value
        guard let items = try? bpmDTOSubject.value() else {
            chart.set(points: [BPMPoint](), for: per)
            historyTableView.setBpmItems([])
            return
        }
       
        let filtered = filter(items, by: per, date: \BPMModelDTO.date)
        let points = mapBpmPoints(filtered)
        chart.set(points: points, for: per)
        historyTableView.setBpmItems(items)
    }
    
    func periodRange(for period: Period,
                     now: Date = Date()) -> (from: Date, to: Date) {
        switch period {
        case .day:
            let to = now
            let from = Calendar.current.date(
                byAdding: .day, value: -1, to: to) ?? to
            return (from, to)
        case .week:
            let to = now
            let from = Calendar.current.date(
                byAdding: .day, value: -7, to: to) ?? to
            return (from, to)
        case .month:
            let to = now
            let from = Calendar.current.date(
                byAdding: .day, value: -30, to: to) ?? to
            return (from, to)
        }
    }

    func filter<T>(_ items: [T],
                   by period: Period,
                   date keyPath: KeyPath<T, Date>) -> [T] {
        let range = periodRange(for: period)
        return items
            .filter { item in
                let d = item[keyPath: keyPath]
                return d >= range.from && d <= range.to
            }
            .sorted { lhs, rhs in
                lhs[keyPath: keyPath] < rhs[keyPath: keyPath]
            }
    }

    func mapTempPoints(_ items: [TempModelDTO]) -> [TempPoint] {
        return items.map { dto in
            let valueC: Double = Double(dto.temp)
            return TempPoint(valueC: valueC, date: dto.date)
        }
    }

    func mapBpmPoints(_ items: [BPMModelDTO]) -> [BPMPoint] {
        return items.map { dto in
            return BPMPoint(bpm: dto.bpm, date: dto.date)
        }
    }
    
}

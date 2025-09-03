//
//  TempConditionVM.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 30.08.25.
//

import Foundation
import RxSwift
import RxCocoa

protocol TempConditionRouterProtocol {
    var selectedDate: Observable<Date> { get }
    var selectedTime: Observable<Date> { get }
    
    func openDatePicker()
    func openTimePicker()
    func openMain()
    func dismiss()
}

protocol TempConditionRealmDataManagerUseCaseProtocol {
    func save(dto: TempModelDTO)
}

final class TempConditionVM: TempConditionViewModelProtocol {
    
    // Out
    @Subject(value: 0.0)
    var temperature: Observable<Double>
    @Subject(value: TemperatureUnit.celsius)
    var tempUnit: Observable<TemperatureUnit>
    @Subject(value: "")
    var datePicked: Observable<String>
    @Subject(value: "")
    var timePicked: Observable<String>
    @Subject(value: Date())
    var pickedDateTime: Observable<Date>
    
    // In
    var saveTapped = PublishRelay<Void>()
    var crossTapped = PublishRelay<Void>()
    var notesText = BehaviorRelay<String?>(value: nil)
    var dateTapped = PublishRelay<Void>()
    var timeTapped = PublishRelay<Void>()
    var siteSelected = BehaviorRelay<MeasuringSiteUnit>(value: MeasuringSiteUnit.oral)
    
    private let router: TempConditionRouterProtocol
    private let symptomsCollection: SymptomsCollectionProtocol
    private let feelingCollection: FeelingctivityCollectionProtocol
    private let realmDataManager: TempConditionRealmDataManagerUseCaseProtocol
    
    private var bag = DisposeBag()
    
    init(router: TempConditionRouterProtocol,
         temperature: Double,
         tempUnit: TemperatureUnit,
         symptomsCollection: SymptomsCollectionProtocol,
         feelingCollection: FeelingctivityCollectionProtocol,
         realmDataManager: TempConditionRealmDataManagerUseCaseProtocol
         
    ) {
        self.router = router
        self._temperature.rx.onNext(temperature)
        self._tempUnit.rx.onNext(tempUnit)
        self.symptomsCollection = symptomsCollection
        self.feelingCollection = feelingCollection
        self.realmDataManager = realmDataManager
        self._pickedDateTime.rx.onNext(Date())
        bind()
    }
    
    private func bind() {
        
        crossTapped.subscribe(onNext: { [weak self] in
            self?.router.dismiss()
        })
        .disposed(by: bag)
        dateTapped.subscribe(onNext: { [weak self] in
            self?.router.openDatePicker()
        })
        .disposed(by: bag)
        timeTapped.subscribe(onNext: { [weak self] in
            self?.router.openTimePicker()
        })
        .disposed(by: bag)
        
        saveTapped
            .withLatestFrom(Observable.combineLatest(
                temperature,
                tempUnit,
                siteSelected.asObservable(),
                feelingCollection.selectedFeeling,
                notesText.asObservable(),
                pickedDateTime,
                symptomsCollection.selectedItems
            ))
            .subscribe(onNext: { [weak self] tuple in
                guard let self else { return }
                let (tempValue, unitEnum, siteEnum, feelingOpt, notesOpt, dateTime, symptoms) = tuple

                let convertTemp: Double = {
                    switch unitEnum {
                    case .celsius: return tempValue
                    case .fahrenheit: return (tempValue - 32.0) * 5.0/9.0
                    }
                }()

                let measureSiteString = siteEnum.rawValue
                let feelingString = feelingOpt?.title

                let symptomsStrings = symptoms.map { $0.rawValue }

                let dto = TempModelDTO(
                    id: UUID().uuidString,
                    date: dateTime,
                    temp: convertTemp,
                    unit: "ºC",
                    measureSite: measureSiteString,
                    symptoms: symptomsStrings,
                    feeling: feelingString,
                    notesText: notesOpt
                )

                self.realmDataManager.save(dto: dto)
                self.router.openMain()
            })
            .disposed(by: bag)
        
        _datePicked.rx.onNext(getCurrenDate())
        _timePicked.rx.onNext(getCurrenTime())
        
        let calendar = Calendar.current

        router.selectedDate
            .withLatestFrom(pickedDateTime) { pickedDate, currentDateTime -> Date in
                let dayStart = calendar.startOfDay(for: pickedDate)
                let comps = calendar.dateComponents([.hour, .minute, .second], from: currentDateTime)
                return calendar.date(bySettingHour: comps.hour ?? 0,
                                     minute: comps.minute ?? 0,
                                     second: comps.second ?? 0,
                                     of: dayStart) ?? dayStart
            }
            .bind(to: _pickedDateTime.rx)
            .disposed(by: bag)

        router.selectedTime
            .withLatestFrom(pickedDateTime) { pickedTime, currentDateTime -> Date in
                let comps = calendar.dateComponents([.year, .month, .day], from: currentDateTime)
                let base = calendar.date(from: comps) ?? currentDateTime
                let timeComps = calendar.dateComponents([.hour, .minute, .second], from: pickedTime)
                return calendar.date(bySettingHour: timeComps.hour ?? 0,
                                     minute: timeComps.minute ?? 0,
                                     second: timeComps.second ?? 0,
                                     of: base) ?? base
            }
            .bind(to: _pickedDateTime.rx)
            .disposed(by: bag)

        pickedDateTime
            .map { date -> String in
                let df = DateFormatter()
                df.dateFormat = "dd.MM.yyyy"
                df.locale = Locale(identifier: "en_US")
                return df.string(from: date)
            }
            .bind(to: _datePicked.rx)
            .disposed(by: bag)

        pickedDateTime
            .map { date -> String in
                let df = DateFormatter()
                df.dateFormat = "hh:mm a"
                df.locale = Locale(identifier: "en_US")
                return df.string(from: date)
            }
            .bind(to: _timePicked.rx)
            .disposed(by: bag)
    }
    
    func getSymptomsCollection() -> UICollectionView {
        symptomsCollection.getCollection()
    }
    
    func getFeelingsCollection() -> UICollectionView {
        feelingCollection.getCollection()
    }
    
    func getCurrenDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: Date())
    }
    
    func getCurrenTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: Date())
    }
    
}

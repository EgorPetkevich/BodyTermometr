//
//  TempDetailsVM.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 4.09.25.
//

import Foundation
import RxSwift
import RxCocoa

protocol TempDetailsRouterProtocol {
    func openEdit(with dto: TempModelDTO)
    func dismiss()
}

protocol TempDetailsAlertManagerServiceUseCaseProtocol {
    func showActionSheetRx(
        firstTitle: String,
        secondTitle: String,
        cancelTitle: String
    ) -> Single<AlertManagerService.SheetChoice>
}

protocol TempDetailsRealmDataManagerUseCaseProtocol {
    func deleteDTO(_ dto: TempModelDTO)
    func updateDTO(_ dto: TempModelDTO)
    func observeTempModel(by id: String) -> Observable<TempModelDTO?>
}

final class TempDetailsVM: TempDetailsViewModelProtocol {
    
    @Relay(value: nil)
    var dtoRelay: Observable<TempModelDTO?>
    
    @Subject(value: Date())
    var dateSubject: Observable<Date>
    
    // Out
    @Subject(value: 0.0)
    var tempSubject: Observable<Double>
    @Subject(value: TempUnit.c)
    var tempUnitSubject: Observable<TempUnit>
    @Subject(value: "")
    var datePicked: Observable<String>
    @Subject(value: "")
    var timePicked: Observable<String>
    @Subject(value: "")
    var noteTextSubject: Observable<String?>
    @Subject(value: "")
    var siteSubject: Observable<String>
    @Subject(value: false)
    var isHiddenSimptoms: Observable<Bool>
    
    // In
    var optionsTapped = PublishRelay<Void>()
    var crossTapped = PublishRelay<Void>()
    var notesText = BehaviorRelay<String?>(value: nil)
    var siteSelected = BehaviorRelay<MeasuringSiteUnit>(value: MeasuringSiteUnit.oral)
    
    private let router: TempDetailsRouterProtocol
    private let symptomsCollection: SymptomsCollectionProtocol
    private let feelingCollection: FeelingctivityCollectionProtocol
    private let alertManagerService: TempDetailsAlertManagerServiceUseCaseProtocol
    private let realmTempManager: TempDetailsRealmDataManagerUseCaseProtocol
    
    private let dto: TempModelDTO
    
    private var bag = DisposeBag()
    
    init(dto: TempModelDTO,
         router: TempDetailsRouterProtocol,
         tempUnit: TempUnit,
         symptomsCollection: SymptomsCollectionProtocol,
         feelingCollection: FeelingctivityCollectionProtocol,
         alertManagerService: TempDetailsAlertManagerServiceUseCaseProtocol,
         realmTempManager: TempDetailsRealmDataManagerUseCaseProtocol
    ) {
        self.router = router
        self.symptomsCollection = symptomsCollection
        self.feelingCollection = feelingCollection
        self.alertManagerService = alertManagerService
        self.realmTempManager = realmTempManager
        self.dto = dto
        _dtoRelay.rx.accept(dto)
        _tempUnitSubject.rx.onNext(.c)
        bind()
    }

    
    private func bind() {
        dtoRelay.subscribe(onNext: { [weak self] dto in
            guard let self ,let dto else { return }
            _tempSubject.rx.onNext(dto.temp)
            _dateSubject.rx.onNext(dto.date)
            _siteSubject.rx.onNext(dto.measureSite)
            _noteTextSubject.rx.onNext(dto.notesText)
            symptomsCollection.items
                .accept(Symptoms.getSymptoms(titles: dto.symptoms))
            _isHiddenSimptoms.rx.onNext(dto.symptoms.isEmpty)
            symptomsCollection.selectAllItem.accept(())
            feelingCollection.items
                .accept([Feeling.getFeeling(title: dto.feeling)])
            feelingCollection.selectAllFeelings.accept(())
        })
        .disposed(by: bag)
        
        realmTempManager.observeTempModel(by: _dtoRelay.rx.value?.id ?? "")
            .bind(to: _dtoRelay.rx)
            .disposed(by: bag)
        
        dateSubject.map { date -> String in
            let df = DateFormatter()
            df.dateFormat = "dd.MM.yyyy"
            df.locale = Locale(identifier: "en_US")
            return df.string(from: date)
        }
        .bind(to: _datePicked.rx)
        .disposed(by: bag)
        
        dateSubject
            .map { date -> String in
                let df = DateFormatter()
                df.dateFormat = "hh:mm a"
                df.locale = Locale(identifier: "en_US")
                return df.string(from: date)
            }
            .bind(to: _timePicked.rx)
            .disposed(by: bag)
        
        
        crossTapped.subscribe(onNext: { [weak self] in
            self?.router.dismiss()
        })
        .disposed(by: bag)

        
        self.optionsTapped
            .flatMapLatest { [weak self] _ -> Observable<AlertManagerService.SheetChoice> in
                guard let self = self else { return .empty() }
                return self.alertManagerService
                    .showActionSheetRx(firstTitle: "Edit",
                                       secondTitle: "Delete",
                                       cancelTitle: "Cancel")
                    .asObservable()
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] choice in
                guard
                    let self = self,
                    let dto = _dtoRelay.rx.value
                else { return }

                switch choice {
                case .first:
                    self.router.openEdit(with: dto)
                case .second:
                    realmTempManager.deleteDTO(dto)
                    self.router.dismiss()
                case .cancel:
                    break
                }
            })
            .disposed(by: self.bag)
    }
    
    func getSymptomsCollection() -> UICollectionView {
        symptomsCollection.getCollection()
    }
    
    func getFeelingsCollection() -> UICollectionView {
        feelingCollection.getCollection()
    }
    
    
}


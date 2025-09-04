//
//  BPMDetailsVM.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 4.09.25.
//

import Foundation
import RxSwift
import RxCocoa

protocol BPMDetailsRouterProtocol {
    func openEdit(with subject: PublishSubject<Int>)
    func dismiss()
}

protocol BPMDetailsRealmBPMManagerUseCaseProtocol {
    func deleteDTO(_ dto: BPMModelDTO)
    func updateDTO(_ dto: BPMModelDTO)
}

protocol BPMDetailsAlertManagerServiceUseCaseProtocol {
    func showActionSheetRx(
        firstTitle: String,
        secondTitle: String,
        cancelTitle: String
    ) -> Single<AlertManagerService.SheetChoice>
}

final class BPMDetailsVM: BPMDetailsViewModelProtocol {
    
    // Out
    @Subject(value: 0)
    var bpm: Observable<Int>
    @Subject(value: "")
    var notesText: Observable<String>
    @Subject(value: nil)
    var noteText: Observable<String?>
    // In
    var optionTapped = PublishRelay<Void>()
    var crossTapped = PublishRelay<Void>()
    
    var selectedActivity = BehaviorRelay<Activity?>(value: nil)
    
    var resultSubject = PublishSubject<Int>()
    
    private var router: BPMDetailsRouterProtocol
    private var collection: ActivityCollectionProtocol
    private var realmBPMManager: BPMDetailsRealmBPMManagerUseCaseProtocol
    private var alertManagerService: BPMDetailsAlertManagerServiceUseCaseProtocol
    
    private var dto: BPMModelDTO
    
    private var bag = DisposeBag()
    
    init(router: BPMDetailsRouterProtocol,
         collection: ActivityCollectionProtocol,
         realmBPMManager: BPMDetailsRealmBPMManagerUseCaseProtocol,
         alertManagerService: BPMDetailsAlertManagerServiceUseCaseProtocol,
         dto: BPMModelDTO) {
        self.router = router
        self.collection = collection
        self.realmBPMManager = realmBPMManager
        self.alertManagerService = alertManagerService
        self.dto = dto
        bind()
    }
    
    private func bind() {
        _bpm.rx.onNext(dto.bpm)
        _noteText.rx.onNext(dto.notesText)
        
        self.resultSubject
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                self.dto.bpm = result
                self.dto.date = .now
                self._bpm.rx.onNext(self.dto.bpm)
                self.realmBPMManager.updateDTO(self.dto)
            })
            .disposed(by: self.bag)
       
        if let activity = Activity.getActivity(title: dto.activity) {
            collection.items.accept([activity])
            collection.selectActivity.accept(())
        }
        collection
            .selectedActivity
            .bind(to: selectedActivity)
            .disposed(by: bag)
        
        crossTapped.subscribe(onNext: { [weak self] in
            self?.router.dismiss()
        })
        .disposed(by: bag)
        
        self.optionTapped
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
                guard let self = self else { return }
                switch choice {
                case .first:
                    self.router.openEdit(with: self.resultSubject)
                case .second:
                    self.realmBPMManager.deleteDTO(self.dto)
                    self.router.dismiss()
                case .cancel:
                    break
                }
            })
            .disposed(by: self.bag)
        
       
    }
    
    func getCollection() -> UICollectionView {
        collection.getCollection()
    }
    
}

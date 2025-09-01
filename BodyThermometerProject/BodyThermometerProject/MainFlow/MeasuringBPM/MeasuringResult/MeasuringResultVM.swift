//
//  MeasuringResultVM.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 27.08.25.
//

import Foundation
import RxSwift
import RxCocoa

protocol MeasuringResultRouterProtocol {
    func openMain()
    func dismiss()
}

protocol MeasuringResultRealmBPMManagerUseCaseProtocol {
    func saveBPM(bpm: Int, activity: String?, notesText: String?)
}

final class MeasuringResultVM: MeasuringResultViewModelProtocol {
    
    // Out
    @Subject(value: 0)
    var bpm: Observable<Int>
    
    // In
    var saveTapped = PublishRelay<Void>()
    var shareTapped = PublishRelay<Void>()
    var crossTapped = PublishRelay<Void>()
    var notesText = BehaviorRelay<String?>(value: nil)
    
    
    var selectedActivity = BehaviorRelay<Activity?>(value: nil)
    
    private var router: MeasuringResultRouterProtocol
    private var collection: ActivityCollectionProtocol
    private var realmManager: MeasuringResultRealmBPMManagerUseCaseProtocol
    
    private var bag = DisposeBag()
    
    init(router: MeasuringResultRouterProtocol,
         collection: ActivityCollectionProtocol,
         realmManager: MeasuringResultRealmBPMManagerUseCaseProtocol,
         bpmResult: Int, ) {
        self.router = router
        self.collection = collection
        self.realmManager = realmManager
        _bpm.rx.onNext(bpmResult)
        bind()
    }
    
    private func bind() {
        collection
            .selectedActivity
            .bind(to: selectedActivity)
            .disposed(by: bag)
        
        let observer = Observable.combineLatest(bpm, selectedActivity, notesText)
        
        saveTapped.withLatestFrom(observer)
            .subscribe(onNext: { [weak self] bpm, activity, notesText in
                self?.realmManager.saveBPM(bpm: bpm,
                                           activity: activity?.title,
                                           notesText: notesText)
                self?.router.openMain()
            })
            .disposed(by: bag)
    }
    
    func getCollection() -> UICollectionView {
        collection.getCollection()
    }
    
}

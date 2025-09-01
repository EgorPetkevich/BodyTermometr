//
//  SymptomsCollection.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 31.08.25.
//

import UIKit
import RxSwift
import RxCocoa

enum Symptoms: String, CaseIterable {
    case cold = "Cold"
    case headache = "Headache"
    case chestCoug = "Chest Cough"
    case dryCough = "Dry Cough"
    case soreThroat = "Sore Throat"
    case runnyNose = "Runny nose"
}

protocol SymptomsCollectionProtocol {
    var selectedItems: Observable<[Symptoms]> { get }
    func getCollection() -> UICollectionView
}

final class SymptomsCollection: NSObject,
                                SymptomsCollectionProtocol,
                                UICollectionViewDelegateFlowLayout {
    private let selectedItemsRelay = BehaviorRelay<[Symptoms]>(value: [])
    var selectedItems: Observable<[Symptoms]> { selectedItemsRelay.asObservable() }

    private lazy var collectionView: UICollectionView = {
        let layout = LeftAlignedFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumLineSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        layout.sectionInset = .zero

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.showsVerticalScrollIndicator = false
        cv.contentInsetAdjustmentBehavior = .never
        cv.allowsMultipleSelection = true
        return cv
    }()

    private let disposeBag = DisposeBag()
    private let items = BehaviorRelay<[Symptoms]>(value: Symptoms.allCases)

    override init() {
        super.init()
        collectionView.register(SymptomChipCell.self,
                                forCellWithReuseIdentifier: "SymptomChipCell")
        bind()
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
    }

    private func bind() {
        items
            .bind(to: collectionView.rx
                .items(cellIdentifier: "SymptomChipCell",
                       cellType: SymptomChipCell.self)) { _, model, cell in
                cell.configure(model.rawValue, selected: false)
            }
            .disposed(by: disposeBag)

        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                (self.collectionView.cellForItem(at: index) as? SymptomChipCell)?
                    .isSelected = true
                let selectedSymptom = self.items.value[index.item]
                var updated = self.selectedItemsRelay.value
                if !updated.contains(selectedSymptom) {
                    updated.append(selectedSymptom)
                    self.selectedItemsRelay.accept(updated)
                }
            })
            .disposed(by: disposeBag)

        collectionView.rx.itemDeselected
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                (self.collectionView.cellForItem(at: index) as? SymptomChipCell)?
                    .isSelected = false
                let deselectedSymptom = self.items.value[index.item]
                let updated = self.selectedItemsRelay.value
                    .filter { $0 != deselectedSymptom }
                self.selectedItemsRelay.accept(updated)
            })
            .disposed(by: disposeBag)
    }

    func getCollection() -> UICollectionView { collectionView }
}

final class LeftAlignedFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(
        in rect: CGRect
    ) -> [UICollectionViewLayoutAttributes]? {
        let attrs = super.layoutAttributesForElements(in: rect)?
            .map { $0.copy() as! UICollectionViewLayoutAttributes }
        var left = sectionInset.left
        var currentY: CGFloat = -1

        attrs?.forEach { a in
            guard a.representedElementCategory == .cell else { return }
            if currentY != a.frame.origin.y {
                currentY = a.frame.origin.y
                left = sectionInset.left
            }
            a.frame.origin.x = left
            left = a.frame.maxX + minimumInteritemSpacing
        }
        return attrs
    }
}

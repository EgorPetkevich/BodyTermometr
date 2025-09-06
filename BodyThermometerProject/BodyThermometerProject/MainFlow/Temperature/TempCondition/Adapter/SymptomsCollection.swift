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
    
    static func getSymptoms(titles: [String]?) -> [Symptoms] {
        guard let titles else { return [] }

        return titles.compactMap { title in
            Self.allCases.first {
                $0.rawValue.caseInsensitiveCompare(title) == .orderedSame
            }
        }
    
    }
}

protocol SymptomsCollectionProtocol {
    var items: BehaviorRelay<[Symptoms]> { get }
    var selectedItems: Observable<[Symptoms]> { get }
    var selectAllItem: PublishRelay<Void> { get }
    var selectItems: PublishRelay<[Symptoms]> { get }
    func getCollection() -> UICollectionView
}

final class SymptomsCollection: NSObject,
                                SymptomsCollectionProtocol,
                                UICollectionViewDelegateFlowLayout {

    var items = BehaviorRelay<[Symptoms]>(value: Symptoms.allCases)
    
    var selectedItems: Observable<[Symptoms]> { selectedItemsRelay.asObservable() }
    var selectAllItem = PublishRelay<Void>()
    var selectItems = PublishRelay<[Symptoms]>()
    
    private let selectedItemsRelay = BehaviorRelay<[Symptoms]>(value: [])
    private var isSelectionLocked = false

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
                       cellType: SymptomChipCell.self)) { [weak self] _, model, cell in
                cell.configure(model.rawValue, selected: false)
                // Keep visual selection in sync with current selected items
                let isSelected = self?.selectedItemsRelay.value.contains(model) ?? false
                cell.isSelected = isSelected
            }
            .disposed(by: disposeBag)

        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                guard !self.isSelectionLocked else { return }
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
                guard !self.isSelectionLocked else { return }
                (self.collectionView.cellForItem(at: index) as? SymptomChipCell)?
                    .isSelected = false
                let deselectedSymptom = self.items.value[index.item]
                let updated = self.selectedItemsRelay.value
                    .filter { $0 != deselectedSymptom }
                self.selectedItemsRelay.accept(updated)
            })
            .disposed(by: disposeBag)
        
        selectAllItem
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }

                var allSelected: [Symptoms] = []
                for section in 0..<collectionView.numberOfSections {
                    for row in 0..<collectionView.numberOfItems(inSection: section) {
                        let indexPath = IndexPath(row: row, section: section)
                        if let cell = self.collectionView.cellForItem(at: indexPath) as? SymptomChipCell {
                            cell.isSelected = true
                        }
                        self.collectionView.selectItem(
                            at: indexPath,
                            animated: false,
                            scrollPosition: []
                        )
                        allSelected.append(self.items.value[row])
                    }
                }
                self.selectedItemsRelay.accept(allSelected)
                
                self.isSelectionLocked = true

            })
            .disposed(by: disposeBag)
        
        selectItems
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] items in
                guard let self = self else { return }
               
                self.collectionView.layoutIfNeeded()

                var selectedItems: [Symptoms] = []
                let data = self.items.value
                for item in items {
                    guard let idx = data.firstIndex(of: item) else { continue }
                    guard self.collectionView.numberOfItems(inSection: 0) > idx else { continue }
                    let indexPath = IndexPath(item: idx, section: 0)

                    self.collectionView.selectItem(
                        at: indexPath,
                        animated: false,
                        scrollPosition: []
                    )
                    if let cell = self.collectionView.cellForItem(at: indexPath) as? SymptomChipCell {
                        cell.isSelected = true
                    }
                    selectedItems.append(item)
                }
                self.selectedItemsRelay.accept(selectedItems)
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

// MARK: - UICollectionViewDelegate (selection gating)
extension SymptomsCollection: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return !isSelectionLocked
    }

    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return !isSelectionLocked
    }
}

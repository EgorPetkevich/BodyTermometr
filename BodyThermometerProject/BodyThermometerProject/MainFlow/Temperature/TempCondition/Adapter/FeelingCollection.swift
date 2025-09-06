//
//  FeelingCollection.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 31.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

enum Feeling: String, CaseIterable {
    case normal, good, bad

    var title: String {
        switch self {
        case .normal:   return "Normal"
        case .good:  return "Good"
        case .bad:  return "Bad"
        }
    }
    var image: UIImage {
        switch self {
        case .normal:   return .feelingNormal
        case .good:  return .feelingGood
        case .bad:  return .feelingBad
        }
    }
    
    static func getFeeling(title: String?) -> Feeling {
        guard
            let title,
            let feeling = Feeling(rawValue: title.lowercased())
        else { return .normal }
        return feeling
    }
    
}

protocol FeelingctivityCollectionProtocol {
    var items: BehaviorRelay<[Feeling]> { get }
    var selectedFeeling: Observable<Feeling?> { get }
    var selectFeeling: PublishRelay<Feeling> { get }
    var selectAllFeelings: PublishRelay<Void> { get }
    func getCollection() -> UICollectionView
    
}

final class FeelingCollection: NSObject,
                          UICollectionViewDelegateFlowLayout,
                               FeelingctivityCollectionProtocol {
    
    @Relay(value: nil)
    var selectedFeeling: Observable<Feeling?>
    var selectAllFeelings = PublishRelay<Void>()
    var selectFeeling = PublishRelay<Feeling>()
    
    var items = BehaviorRelay<[Feeling]>(value: Feeling.allCases)
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 114, height: 112)
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = .zero
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.scrollIndicatorInsets = .zero
        cv.allowsSelection = true
        return cv
    }()
    
    private let disposeBag = DisposeBag()
    private var isSelectionLocked = false
    
    override init() {
        super.init()
        setupCollection()
        bind()
    }
    
    private func setupCollection() {
        collectionView.register(FeelingCell.self)
    }
    
    private func bind() {
        items
            .bind(to: collectionView.rx.items(
                cellIdentifier: "\(FeelingCell.self)",
                cellType: FeelingCell.self)
            ) { _, model, cell in
                cell.configure(with: model)
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(Feeling.self)
            .subscribe(onNext: { [weak self] activity in
                guard let self = self, !self.isSelectionLocked else { return }
                print("Selected:", activity)
                self._selectedFeeling.rx.accept(activity)
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        
        selectFeeling.observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] feeling in
                guard let self = self else { return }
                let data = self.items.value
                guard let idx = data.firstIndex(of: feeling) else { return }
                let indexPath = IndexPath(item: idx, section: 0)

                guard self.collectionView.numberOfItems(inSection: 0) > idx else { return }
                self.collectionView.selectItem(
                    at: indexPath,
                    animated: true,
                    scrollPosition: []
                )
               
                self._selectedFeeling.rx.accept(feeling)
            })
            .disposed(by: disposeBag)
        
        selectAllFeelings
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self, !items.value.isEmpty else { return }

                var allSelected: [Feeling] = []
                for section in 0..<collectionView.numberOfSections {
                    for row in 0..<collectionView.numberOfItems(inSection: section) {
                        let indexPath = IndexPath(row: row, section: section)
                        if let cell = self.collectionView.cellForItem(at: indexPath) as? FeelingCell {
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
                if let first = allSelected.first {
                    self._selectedFeeling.rx.accept(first)
                }
                self.isSelectionLocked = true
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Flow layout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flow = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize(width: 114, height: 112)
        }
        let columns: CGFloat = 3
        let spacing = flow.minimumInteritemSpacing
        let totalHorizontalInsets = flow.sectionInset.left + flow.sectionInset.right
        let totalSpacing = spacing * (columns - 1) + totalHorizontalInsets
        let width = floor((collectionView.bounds.width - totalSpacing) / columns)
        return CGSize(width: width, height: 112)
    }
    
    func getCollection() -> UICollectionView {
        return collectionView
    }
}

extension FeelingCollection: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return !isSelectionLocked
    }

    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return !isSelectionLocked
    }
}

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

enum Feeling: CaseIterable {
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
}

protocol FeelingctivityCollectionProtocol {
    var selectedFeeling: Observable<Feeling?> { get }
    func getCollection() -> UICollectionView
    
}

final class FeelingCollection: NSObject,
                          UICollectionViewDelegateFlowLayout,
                               FeelingctivityCollectionProtocol {
    
    @Relay(value: nil)
    var selectedFeeling: Observable<Feeling?>
    
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
    
    override init() {
        super.init()
        setupCollection()
        bind()
    }
    
    private func setupCollection() {
        collectionView.register(FeelingCell.self)
    }
    
    private func bind() {
        let items = Observable.just(Feeling.allCases)
        
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
                print("Selected:", activity)
                self?._selectedFeeling.rx.accept(activity)
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
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

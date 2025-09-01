//
//  ActivityView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 28.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol ActivityCollectionProtocol {
    var selectedActivity: Observable<Activity?> { get }
    func getCollection() -> UICollectionView
    
}

final class ActivityCollection: NSObject,
                          UICollectionViewDelegateFlowLayout,
                          ActivityCollectionProtocol {
    
    @Relay(value: nil)
    var selectedActivity: Observable<Activity?>
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
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
        collectionView.register(ActivityCell.self)
    }
    
    private func bind() {
        let items = Observable.just(Activity.allCases)
        
        items
            .bind(to: collectionView.rx.items(
                cellIdentifier: "\(ActivityCell.self)",
                cellType: ActivityCell.self)
            ) { _, model, cell in
                cell.configure(with: model)
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(Activity.self)
            .subscribe(onNext: { [weak self] activity in
                print("Selected:", activity)
                self?._selectedActivity.rx.accept(activity)
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    // MARK: - Flow layout
    func collectionView(_ collectionView: UICollectionView,
                        layout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flow = layout as! UICollectionViewFlowLayout
        let inset = flow.sectionInset
        let spacing = flow.minimumInteritemSpacing
        let total = inset.left + inset.right + spacing
        let w = (collectionView.bounds.width - total) / 2.0
        return CGSize(width: floor(w), height: 112)
    }
    
    func getCollection() -> UICollectionView {
        return collectionView
    }
}

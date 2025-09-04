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
   // Out
    var selectedActivity: Observable<Activity?> { get }
    func getCollection() -> UICollectionView
    // In
    var items: BehaviorRelay<[Activity]> { get }
    var selectActivity: PublishRelay<Void> { get }
    var allowSelection: Bool { get set }
}

final class ActivityCollection: NSObject,
                                UICollectionViewDelegateFlowLayout,
                                ActivityCollectionProtocol {
    
    // Out
    @Relay(value: nil)
    var selectedActivity: Observable<Activity?>
    
    // In
    var items = BehaviorRelay(value: Activity.allCases)
    var selectActivity = PublishRelay<Void>()
    
    var allowSelection: Bool {
        get { collectionView.allowsSelection }
        set { collectionView.allowsSelection = newValue }
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.scrollIndicatorInsets = .zero
        cv.allowsSelection = true
        cv.allowsMultipleSelection = false
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
        
        collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        selectActivity
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.collectionView.selectItem(
                        at: indexPath,
                        animated: true,
                        scrollPosition: []
                    )
                })
            .disposed(by: disposeBag)
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

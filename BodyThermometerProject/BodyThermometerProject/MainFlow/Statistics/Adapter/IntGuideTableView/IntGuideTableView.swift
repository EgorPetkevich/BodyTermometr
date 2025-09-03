//
//  IntGuideTableView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 3.09.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import RxRelay

enum IntGuide {
    case temp([IntGuideTempSection.IntGuideTemp])
    case bpm([IntGuideBpmSection.IntGuideBpm])
}

protocol IntGuideTableViewProtocol {
    var modeRelay: BehaviorRelay<IntGuide> { get }
    var currentUnitRelay: BehaviorRelay<TempUnit> { get }
    func getTable() -> UITableView
    func setTempItems(_ items: [IntGuideTempSection.IntGuideTemp])
    func setBpmItems(_ items: [IntGuideBpmSection.IntGuideBpm])
}

final class IntGuideTableView: NSObject,
                               UITableViewDataSource,
                               UITableViewDelegate,
                               IntGuideTableViewProtocol {
    
    private enum LayoutConst {
        static let rowHeight: CGFloat = 44.0
       
    }
    
    var modeRelay = BehaviorRelay<IntGuide>(value: .temp([]))
    let currentUnitRelay = BehaviorRelay<TempUnit>(value: .c)
    
    private(set) lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.isScrollEnabled = true
        tv.showsVerticalScrollIndicator = false
        tv.separatorStyle = .none
        tv.allowsSelection = false
        tv.rowHeight = LayoutConst.rowHeight
        return tv
    }()
    
    private let disposeBag = DisposeBag()
    
    override init() {
        super.init()
        setup()
        bind()
    }
    
    private func setup() {
        tableView.register(IntGuideCell.self)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func bind() {
        modeRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        currentUnitRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    func setTempItems(_ items: [IntGuideTempSection.IntGuideTemp]) {
        modeRelay.accept(.temp(items))
    }

    func setBpmItems(_ items: [IntGuideBpmSection.IntGuideBpm]) {
        modeRelay.accept(.bpm(items))
    }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        switch modeRelay.value {
        case .temp(let items): return items.count
        case .bpm(let items): return items.count
        }
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        switch modeRelay.value {
        case .temp(let items):
            let cell: IntGuideCell = tableView.dequeue(at: indexPath)
            let model = items[indexPath.row]
            let unit = currentUnitRelay.value
            cell.configure(with: model, tepmUnit: unit)
            return cell
        case .bpm(let items):
            let cell: IntGuideCell = tableView.dequeue(at: indexPath)
            let model = items[indexPath.row]
            cell.configure(with: model)
            return cell
        }
    }
    
    
    func getTable() -> UITableView { tableView }
}


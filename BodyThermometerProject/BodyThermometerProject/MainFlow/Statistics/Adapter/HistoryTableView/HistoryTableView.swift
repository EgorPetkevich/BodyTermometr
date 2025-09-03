//
//  HistoryTableView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 2.09.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import RxRelay

enum Mode {
    case temp([TempModelDTO])
    case bpm([BPMModelDTO])
}

protocol HistoryTableViewTableViewProtocol {
    var currentUnitRelay: BehaviorRelay<TempUnit> { get }
    func getTable() -> UITableView
    func setTempItems(_ items: [TempModelDTO])
    func setBpmItems(_ items: [BPMModelDTO])
}

final class HistoryTableView: NSObject,
                              UITableViewDataSource,
                              UITableViewDelegate,
                              HistoryTableViewTableViewProtocol {
    private enum LayoutConst {
        static let rowHeight: CGFloat = 80.0
        static let sectionFooterHeight: CGFloat = 16.0
    }
    
    // Empty state overlay
    private let emptyOverlay = UIView()
    
    private let emptTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Start a measurement to view your heart rate here."
        l.numberOfLines = 0
        l.textAlignment = .center
        l.font = .appMediumFont(ofSize: 18)
        l.textColor = .appBlack
        return l
    }()
    
    private let emptSubTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Start your first measurement to see your \nbody temperature here."
        l.numberOfLines = 2
        l.textAlignment = .center
        l.font = .appRegularFont(ofSize: 15)
        l.textColor = .appBlack.withAlphaComponent(0.6)
        return l
    }()
    
    @Relay()
    var tempSelected: Observable<TempModelDTO>
    @Relay()
    var bpmSelected: Observable<BPMModelDTO>
    
    var modeRelay = BehaviorRelay<Mode>(value: .temp([]))
    let currentUnitRelay = BehaviorRelay<TempUnit>(value: .c)
    
    private(set) lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.isScrollEnabled = true
        tv.showsVerticalScrollIndicator = false
        tv.separatorStyle = .none
        tv.allowsSelection = true
        tv.allowsMultipleSelection = false
        tv.sectionFooterHeight = LayoutConst.sectionFooterHeight
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
        tableView.register(TempCell.self)
        tableView.register(BpmCell.self)
        tableView.dataSource = self
        tableView.delegate = self

        emptyOverlay.backgroundColor = .white
        emptyOverlay.frame = tableView.bounds
        emptyOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.backgroundView = emptyOverlay
        emptyOverlay.isHidden = true

        emptyOverlay.addSubview(emptTitleLabel)
        emptyOverlay.addSubview(emptSubTitleLabel)

        emptTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(emptyOverlay.snp.centerY).offset(-4)
            make.leading.greaterThanOrEqualToSuperview().inset(16)
            make.trailing.lessThanOrEqualToSuperview().inset(16)
        }
        emptSubTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emptyOverlay.snp.centerY).offset(4)
            make.leading.greaterThanOrEqualToSuperview().inset(16)
            make.trailing.lessThanOrEqualToSuperview().inset(16)
        }
    }
    
    func setupEmptyOverlay() {
        
    }
    
    private func bind() {
        modeRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
                self?.updateEmptyOverlay()
            })
            .disposed(by: disposeBag)
        
        currentUnitRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    func setTempItems(_ items: [TempModelDTO]) {
        modeRelay.accept(.temp(items))
    }

    func setBpmItems(_ items: [BPMModelDTO]) {
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
            let cell: TempCell = tableView.dequeue(at: indexPath)
            let model = items[indexPath.row]
            let unit = currentUnitRelay.value
            cell.configure(model, unit: unit)
            return cell
        case .bpm(let items):
            let cell: BpmCell = tableView.dequeue(at: indexPath)
            let model = items[indexPath.row]
            cell.configure(model)
            return cell
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch modeRelay.value {
        case .temp(let items):
            let model = items[indexPath.row]
            _tempSelected.rx.accept(model)
        case .bpm(let items):
            let model = items[indexPath.row]
            _bpmSelected.rx.accept(model)
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        cell.contentView.layer.cornerRadius = 24
        cell.contentView.layer.masksToBounds = true
    }
    
    
    private func updateEmptyOverlay() {
        let isEmpty: Bool
        switch modeRelay.value {
        case .temp(let items):
            isEmpty = items.isEmpty
        case .bpm(let items):
            isEmpty = items.isEmpty
        }
        if isEmpty { updateEmptyTitleText() }
        emptyOverlay.isHidden = !isEmpty
    }
    
    private func updateEmptyTitleText() {
        switch modeRelay.value {
        case .temp:
            emptTitleLabel.text = "No Temperature Recorded Yet"
            emptSubTitleLabel.text = "Start your first measurement to see your \nbody temperature here."
        case .bpm:
            emptTitleLabel.text = "No Heart Rate Recorded"
            emptSubTitleLabel.text = "Start a measurement to view your \nheart rate here."
        }
    }

    func getTable() -> UITableView { tableView }
}

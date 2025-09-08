//
//  StatisticsVC.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 1.09.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import DGCharts

protocol StatisticsViewModelProtocol {
    // Out
    var setDayPeriodRelay: Observable<Period> { get }
    // In
    var tempUnitState: BehaviorRelay<TempUnit> { get }
    var modeSelected: BehaviorRelay<StatMode> { get }
    var periodSelected: BehaviorRelay<Period> { get }
    var crossButtonTapped: PublishRelay<Void> { get }
    
    func getChartView() -> ScatterChartView
    func getHistoryTableViewView() -> UITableView
    func getIntGuideTableView() -> UITableView
}

final class StatisticsVC: UIViewController {
    
    private enum SheetState { case collapsed, half, expanded }

    private var sheetState: SheetState = .collapsed
    private var tableTopConstraint: Constraint?
    private var historyGuideTopConstraint: Constraint?
    private var collapsedTop: CGFloat = 0
    private var halfTop: CGFloat = 0
    private var expandedTop: CGFloat = 0
    private var panStartTop: CGFloat = 0
    
    private enum TextConst {
        static let titleText = "Statistics Data"
        static let tempChartTitle: String = "Body temperature"
        static let bpmChartTitle: String = "Heart Rate Statistics"
    }
    
    private enum LayoutConst {
        static let crossButtonSize: CGFloat = 48.0
        
        static let chartContainerViewHeight: CGFloat = 240.0
        static let chartContainerViewRadius: CGFloat = 24.0
        static let tempUnitControlViewSize: CGSize = .init(width: 80.0,
                                                           height: 28.0)
        static let tempBPMControlViewSize: CGSize = .init(width: 250.0,
                                                          height: 25.0)
    }
    
    private lazy var titleLabel: UILabel =
        .mediumTitleLabel(withText: TextConst.titleText, ofSize: 24.0)
    
    private lazy var crossButton: UIButton =
    UIButton(type: .system)
        .setImage(.crossIconBlack)
        .setTintColor(.appBlack)
        .setBgColor(.appWhite)
    
    // Chart
    private lazy var chartContainerView: UIView = UIView().bgColor(.appWhite)
    private lazy var chartTitleLabel: UILabel =
        .mediumTitleLabel(withText: "", ofSize: 18.0)
    private lazy var chart: ScatterChartView =
    viewModel.getChartView()
    private lazy var chartPeriodControlView: ChartPeriodControlView =
    ChartPeriodControlView()
    private lazy var tempUnitControlView: TempUnitControlView =
    TempUnitControlView()
    
    private lazy var tempBPMControlView: TempBPMControlView =
    TempBPMControlView()
    
    private lazy var historyGuideControlView: HistoryGuideControlView =
    HistoryGuideControlView()
    
    private lazy var tableViewContainer: UIView = UIView().bgColor(.appWhite)
    private lazy var historyTableView: UITableView =
    viewModel.getHistoryTableViewView()
    private lazy var segmentView = UIView().bgColor(.appSegment)
    
    private lazy var intGuideTableView: UITableView =
    viewModel.getIntGuideTableView()
    
    private var viewModel: StatisticsViewModelProtocol
    
    private var bag = DisposeBag()
    
    init(viewModel: StatisticsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        commonInit()
        setupSnapKitConstrains()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        bindButtons()
        bindTable()
        bindChart()
    }
    
    private func bindButtons() {
        crossButton.rx.tap
            .bind(to: viewModel.crossButtonTapped)
            .disposed(by: bag)
    }
    
    private func bindTable() {
        historyGuideControlView.rx.segment
            .subscribe(onNext: { [weak self] segment in
                guard let self else { return }
                historyTableView.isHidden = segment == .guide
                intGuideTableView.isHidden = segment == .history
            })
            .disposed(by: bag)
    }
    
    private func bindChart() {
        tempBPMControlView.rx.mode
            .map { mode -> String in
                switch mode {
                case .temperature:
                    TextConst.tempChartTitle
                case .heartRate:
                    TextConst.bpmChartTitle
                }
            }
            .bind(to: chartTitleLabel.rx.text)
            .disposed(by: bag)
        tempBPMControlView.rx.mode
            .map { mode -> Bool in
                switch mode {
                case .temperature: false
                case .heartRate: true
                }
            }
            .bind(to: tempUnitControlView.rx.isHidden)
            .disposed(by: bag)
        
        tempBPMControlView.rx.mode
            .bind(to: viewModel.modeSelected)
            .disposed(by: bag)
        tempUnitControlView.rx.state
            .bind(to: viewModel.tempUnitState)
            .disposed(by: bag)
        chartPeriodControlView.rx.period
            .bind(to: viewModel.periodSelected)
            .disposed(by: bag)
        viewModel.setDayPeriodRelay
            .subscribe(onNext: { [weak self] period in
                self?.chartPeriodControlView.setSelected(period)
            })
            .disposed(by: bag)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        expandedTop = 0
        if
            let anchor = chartContainerView
                .superview?
                .convert(chartContainerView.frame, to: view)
        {
            collapsedTop = anchor.maxY + 16.0
        }
        halfTop = (collapsedTop + expandedTop) / 2.0
        snap(to: sheetState, animated: false)
    }
    
}

//MARK: - Private
private extension StatisticsVC {
    
    func commonInit() {
        view.backgroundColor = .appBg
        view.addSubview(titleLabel)
        view.addSubview(crossButton)
        view.addSubview(tempBPMControlView)
        view.addSubview(chartContainerView)
        chartContainerView.addSubview(chartTitleLabel)
        chartContainerView.addSubview(chart)
        chartContainerView.addSubview(chartPeriodControlView)
        chartContainerView.addSubview(tempUnitControlView)
        
        view.addSubview(tableViewContainer)
        tableViewContainer.addSubview(historyTableView)
        tableViewContainer.addSubview(historyGuideControlView)
        tableViewContainer.addSubview(segmentView)
        tableViewContainer.addSubview(intGuideTableView)
        intGuideTableView.isHidden = true
        setupSheetGestures()
        
        tableViewContainer.layer.cornerRadius = 32
        tableViewContainer.layer.masksToBounds = true
        tableViewContainer.layer.maskedCorners =
        [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func setupSnapKitConstrains() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(17.0)
        }
        
        crossButton.snp.makeConstraints { make in
            make.size.equalTo(LayoutConst.crossButtonSize)
            make.left.equalToSuperview().inset(16.0)
            make.centerY.equalTo(titleLabel.snp.centerY)
        }
        crossButton.radius = LayoutConst.crossButtonSize / 2
        tempBPMControlView.snp.makeConstraints { make in
            make.top.equalTo(crossButton.snp.bottom).offset(18.0)
            make.centerX.equalToSuperview()
            make.size.equalTo(LayoutConst.tempBPMControlViewSize)
        }
        chartContainerView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16.0)
            make.top.equalTo(tempBPMControlView.snp.bottom).offset(14.0)
            make.height.equalTo(LayoutConst.chartContainerViewHeight)
        }
        chartContainerView.radius = LayoutConst.chartContainerViewRadius
        chartTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(19.0)
            make.left.equalToSuperview().inset(16.0)
        }
        chart.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16.0)
            make.verticalEdges.equalToSuperview().inset(60.0)
        }
        chartPeriodControlView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview().inset(18.0)
        }
        tempUnitControlView.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(16.0)
            make.size.equalTo(LayoutConst.tempUnitControlViewSize)
        }
        tempBPMControlView.radius = 7.0
        
        tableViewContainer.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            self.tableTopConstraint = make.top.equalToSuperview().offset(0).constraint
        }
        historyGuideControlView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16.0)
            self.historyGuideTopConstraint =
            make.top.equalToSuperview().inset(28.0).constraint
        }
        historyTableView.snp.makeConstraints { make in
            make.top.equalTo(historyGuideControlView.snp.bottom).offset(8.0)
            make.left.right.bottom.equalToSuperview().inset(16.0)
        }
        intGuideTableView.snp.makeConstraints { make in
            make.top.equalTo(historyGuideControlView.snp.bottom).offset(8.0)
            make.left.right.bottom.equalToSuperview().inset(16.0)
        }
        segmentView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 40.0, height: 4.0))
            make.top.equalToSuperview().inset(8.0)
            make.centerX.equalToSuperview()
        }
        segmentView.radius = 2.0
        
    }
    
    // MARK: - Bottom sheet behavior for tableViewContainer
    func setupSheetGestures() {
        let pan = UIPanGestureRecognizer(
            target: self, action: #selector(handleSheetPan(_:)))
        tableViewContainer.addGestureRecognizer(pan)
        historyTableView.panGestureRecognizer.addTarget(
            self, action: #selector(handleSheetPan(_:)))
    }

    @objc private func handleSheetPan(_ gr: UIPanGestureRecognizer) {
        let translation = gr.translation(in: view).y
        let velocity = gr.velocity(in: view).y

        switch gr.state {
        case .began:
            if
                sheetState != .expanded ||
                (sheetState == .expanded &&
                 historyTableView.contentOffset.y <= 0 && velocity > 0)
            {
                historyTableView.setContentOffset(.zero, animated: false)
                historyTableView.isScrollEnabled = false
            }
            panStartTop = tableTopConstraint?.layoutConstraints.first?.constant ?? 0
        case .changed:
            
            if
                sheetState != .expanded ||
                (sheetState == .expanded &&
                 historyTableView.contentOffset.y <= 0 && velocity > 0)
            {
                let proposed = panStartTop + translation
                let clamped = max(expandedTop, min(collapsedTop, proposed))
                tableTopConstraint?.update(offset: clamped)
                view.layoutIfNeeded()
            }
        case .ended, .cancelled, .failed:
            historyTableView.isScrollEnabled = true
            let currentTop =
            tableTopConstraint?.layoutConstraints.first?.constant ?? collapsedTop
            let target: SheetState
            if abs(velocity) > 600 {
                target = (velocity < 0) ? .expanded : .collapsed
            } else {
                let distances: [(SheetState, CGFloat)] =
                [(.expanded, abs(currentTop - expandedTop)),
                (.half, abs(currentTop - halfTop)),
                (.collapsed, abs(currentTop - collapsedTop))]
                target = distances.min(by: { $0.1 < $1.1 })?.0 ?? .collapsed
            }
            snap(to: target, animated: true)
        default:
            break
        }
    }

    private func snap(to state: SheetState, animated: Bool) {
        sheetState = state
        let targetTop: CGFloat
        switch state {
        case .collapsed: targetTop = collapsedTop
        case .half:      targetTop = halfTop
        case .expanded:  targetTop = expandedTop
        }
        let applySegmentVisibility = {
            let shouldHide = (state == .expanded)
            self.segmentView.alpha = shouldHide ? 0 : 1
            self.segmentView.isHidden = shouldHide
        }
        let updateGuideTopInset = {
            let inset: CGFloat = (state == .expanded) ? 72.0 : 28.0
            self.historyGuideTopConstraint?.update(inset: inset)
        }
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0,
                           options: [.curveEaseInOut, .allowUserInteraction])
            {
                self.tableTopConstraint?.update(offset: targetTop)
                updateGuideTopInset()
                applySegmentVisibility()
                self.view.layoutIfNeeded()
            }
        } else {
            self.tableTopConstraint?.update(offset: targetTop)
            updateGuideTopInset()
            applySegmentVisibility()
            self.view.layoutIfNeeded()
        }
    }
    
}

//
//  BPMChartView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 1.09.25.
//


import UIKit
import DGCharts
import RxSwift
import RxCocoa
import SnapKit

enum Period: CaseIterable {
    case day, week, month
}

protocol StatChartViewProtocol {
    var selectedPeriodRelay: BehaviorRelay<Period> { get }
    var selectedUnit: BehaviorRelay<TempUnit> { get }
    
    func set(points: [BPMPoint], for period: Period)
    func set(points: [TempPoint], for period: Period)
    func set(period: Period)
    func getChart() -> ScatterChartView
}


final class FixedDecimalValueFormatter: ValueFormatter {
    private let formatter: NumberFormatter
    private let decimals: Int
    init(decimals: Int) {
        self.decimals = decimals
        let nf = NumberFormatter()
        nf.locale = Locale(identifier: "en_US_POSIX")
        nf.numberStyle = .decimal
        nf.groupingSize = 0
        nf.usesGroupingSeparator = false
        nf.decimalSeparator = "."
        nf.minimumFractionDigits = decimals
        nf.maximumFractionDigits = decimals
        self.formatter = nf
        
    }
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "% .\(decimals)f", value)
    }
}

final class StatChartView: ScatterChartView, StatChartViewProtocol {
    
    private enum RenderKind {
        case temp, bpm
    }

    private let bag = DisposeBag()

    var selectedPeriodRelay = BehaviorRelay<Period>(value: .day)
    var selectedUnit = BehaviorRelay<TempUnit>(value: .c)
    
    private var lastKind: RenderKind?
    private var bpmStore: [Period: [BPMPoint]] = [:]
    private var tempStore: [Period: [TempPoint]] = [:]
    
    private let tempOvalRenderer = OvalShapeRenderer()

    // Empty state overlay
    private let emptyOverlay = UIView()
    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "No data available"
        l.textAlignment = .center
        l.font = .appRegularFont(ofSize: 15)
        l.textColor = .appBlack
        l.numberOfLines = 0
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        bind()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    var periodObservable: Observable<Period> {
        selectedPeriodRelay.asObservable().distinctUntilChanged()
    }
    
    func set(period: Period) {
        selectedPeriodRelay.accept(period)
    }
    
    func getChart() -> ScatterChartView {
        return self
    }
    
    private func bind() {
        selectedPeriodRelay.asObservable()
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.renderCurrent()
            })
            .disposed(by: bag)

        selectedUnit.asObservable()
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.renderCurrent()
            })
            .disposed(by: bag)
    }
    

    private func inferPeriod(from dates: [Date]) -> Period {
        guard let minDate = dates.min(), let maxDate = dates.max() else { return selectedPeriodRelay.value }
        let span = maxDate.timeIntervalSince(minDate)
        let day: TimeInterval = 24 * 60 * 60
        let week: TimeInterval = 7 * day
        if span <= day { return .day }
        if span <= week { return .week }
        return .month
    }

    // Render helpers that don't infer period
    private func renderBPM(_ points: [BPMPoint]) {
        lastKind = .bpm
        guard !points.isEmpty else {
            self.data = nil
            self.emptyOverlay.isHidden = false
            return
        }
        self.emptyOverlay.isHidden = false

        let entries: [ChartDataEntry] = points.enumerated().map { (idx, p) in
            ChartDataEntry(x: Double(idx), y: Double(p.bpm))
        }

        let set = ScatterChartDataSet(entries: entries, label: "")
        set.setScatterShape(.circle)
        set.scatterShapeSize = 16
        set.drawValuesEnabled = true
        set.valueFont = .appRegularFont(ofSize: 12)
        set.valueColors = points.map { $0.color }
        set.valueFormatter = FixedDecimalValueFormatter(decimals: 1)
        set.setColor(.clear)
        set.drawIconsEnabled = false
        set.highlightEnabled = false

        let data = ScatterChartData(dataSet: set)
        self.data = data
        self.emptyOverlay.isHidden = true
        set.colors = points.map { $0.color }
        configureAxesForBPM()
        self.setNeedsDisplay()
    }

    private func renderTemp(_ points: [TempPoint]) {
        lastKind = .temp
        guard !points.isEmpty else {
            self.data = nil
            self.emptyOverlay.isHidden = false
            return
        }
        self.emptyOverlay.isHidden = false

        let unit = selectedUnit.value
        let entries: [ChartDataEntry] = points.enumerated().map { (idx, p) in
            let value: Double = (unit == .c) ? p.valueC : (p.valueC * 9 / 5 + 32)
            return ChartDataEntry(x: Double(idx), y: value)
        }

        let set = ScatterChartDataSet(entries: entries, label: "")
        set.shapeRenderer = tempOvalRenderer
        set.scatterShapeSize = 12
        set.drawValuesEnabled = true
        set.valueFont = .appRegularFont(ofSize: 12)
        set.valueFormatter = FixedDecimalValueFormatter(decimals: 1)
        set.setColor(.clear)
        set.valueColors = points.map { $0.color }
        set.colors = points.map { $0.color }
        set.drawIconsEnabled = false
        set.highlightEnabled = false

        let data = ScatterChartData(dataSet: set)
        self.data = data
        self.emptyOverlay.isHidden = true
        configureAxesForTemp()
        self.setNeedsDisplay()
    }

    func set(points: [BPMPoint]) {
        let period = inferPeriod(from: points.map { $0.date })
        bpmStore[period] = points
        self.renderBPM(points)
    }
    
    func set(points: [TempPoint]) {
        let period = inferPeriod(from: points.map { $0.date })
        tempStore[period] = points
        self.renderTemp(points)
    }

    func set(points: [BPMPoint], for period: Period) {
        bpmStore[period] = points
        if period == selectedPeriodRelay.value {
            self.renderBPM(points)
        } else {
            self.data = nil
            self.emptyOverlay.isHidden = points.isEmpty == false ? false : true
        }
    }

    func set(points: [TempPoint], for period: Period) {
        tempStore[period] = points
        if period == selectedPeriodRelay.value {
            self.renderTemp(points)
        } else {
            self.data = nil
            self.emptyOverlay.isHidden = points.isEmpty == false ? false : true
        }
    }

    // MARK: - Private
    private func setup() {
        
        self.chartDescription.enabled = false
        self.legend.enabled = false
        self.pinchZoomEnabled = false
        self.doubleTapToZoomEnabled = false
        self.dragEnabled = false
        self.scaleXEnabled = false
        self.scaleYEnabled = false
        self.highlightPerTapEnabled = false
        self.drawGridBackgroundEnabled = false
        self.backgroundColor = .clear
        self.noDataText = ""
       
        self.extraTopOffset = 25
        self.extraBottomOffset = 20
        self.extraRightOffset = 10
       
        self.clipValuesToContentEnabled = false
        self.clipDataToContentEnabled = false
        
        
        configureStaticAxes()
        
        // Empty state setup
        emptyOverlay.backgroundColor = .white
        emptyOverlay.isHidden = true
        addSubview(emptyOverlay)
        emptyOverlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        emptyOverlay.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview().inset(16)
            make.right.lessThanOrEqualToSuperview().inset(16)
        }
    }

    private func configureStaticAxes() {
        let x = self.xAxis
        x.enabled = false

        let left = self.leftAxis
        left.enabled = false

        let right = self.rightAxis
        right.enabled = true
        right.labelFont = .appRegularFont(ofSize: 12.0)
        right.labelTextColor = .appGrey
        right.drawAxisLineEnabled = false
        right.drawGridLinesEnabled = true
        right.gridColor = .appGrey.withAlphaComponent(0.2)
        right.gridLineWidth = 1
        right.gridLineDashLengths = [2, 0]
        right.axisMinimum = 35
        right.axisMaximum = 140
        right.granularity = 35
        right.labelCount = 4
        right.forceLabelsEnabled = true
    }

    private func configureAxesForTemp() {
        let axis = self.rightAxis
        switch selectedUnit.value {
        case .c:
            axis.axisMinimum = 20
            axis.axisMaximum = 50
            axis.granularity = 10
            axis.labelCount = 4
        case .f:
            axis.axisMinimum = 60
            axis.axisMaximum = 120
            axis.granularity = 20
            axis.labelCount = 4
        }
        axis.forceLabelsEnabled = true
        axis.valueFormatter = DefaultAxisValueFormatter(decimals: selectedUnit.value == .c ? 0 : 0)
        axis.drawGridLinesEnabled = true
        axis.spaceTop = 0.2
        axis.spaceBottom = 0.05
    }

    private func configureAxesForBPM() {
        let axis = self.rightAxis
        axis.axisMinimum = 35
        axis.axisMaximum = 140
        axis.granularity = 35
        axis.labelCount = 4
        axis.forceLabelsEnabled = true
        axis.valueFormatter = DefaultAxisValueFormatter(decimals: 0)
        axis.drawGridLinesEnabled = true
        axis.spaceTop = 0.2
        axis.spaceBottom = 0.05
    }
    
    private func renderCurrent() {
        let period = selectedPeriodRelay.value
        switch lastKind {
        case .bpm:
            if let pts = bpmStore[period] { self.renderBPM(pts) } else { self.data = nil }
        case .temp:
            if let pts = tempStore[period] { self.renderTemp(pts) } else { self.data = nil }
        case .none:
            if let pts = tempStore[period] { lastKind = .temp; self.renderTemp(pts) }
            else if let pts = bpmStore[period] { lastKind = .bpm; self.renderBPM(pts) }
            else { self.data = nil }
        }
        self.emptyOverlay.isHidden = (self.data != nil)
    }
    
}

// MARK: - Custom Shape Renderer for Temp points (12x56 oval)
final class OvalShapeRenderer: ShapeRenderer {
    private let width: CGFloat
    private let height: CGFloat

    init(width: CGFloat = 12, height: CGFloat = 56) {
        self.width = width
        self.height = height
    }
    

    func renderShape(
        context: CGContext,
        dataSet: ScatterChartDataSetProtocol,
        viewPortHandler: ViewPortHandler,
        point: CGPoint,
        color: NSUIColor
    ) {
        context.saveGState()
        defer { context.restoreGState() }

        let rect = CGRect(
            x: point.x - width / 2,
            y: point.y - height + 45,
            width: width,
            height: height
        )

        let cornerRadius = width / 2
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        context.addPath(path.cgPath)
        context.clip()

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let startColor = (color as UIColor).withAlphaComponent(1.0).cgColor
        let endColor = (color as UIColor).withAlphaComponent(0.0).cgColor
        let colors = [startColor, endColor] as CFArray
        let locations: [CGFloat] = [0.0, 1.0]

        if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
            let startPoint = CGPoint(x: rect.midX, y: rect.minY)
            let endPoint = CGPoint(x: rect.midX, y: rect.maxY)
            context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        }
    }
}

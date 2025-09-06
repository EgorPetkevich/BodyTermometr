//
//  TempDetailsVC.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 4.09.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol TempDetailsViewModelProtocol {
    // Out
    var tempSubject: Observable<Double> { get }
    var tempUnitSubject: Observable<TempUnit> { get }
    var datePicked: Observable<String> { get }
    var timePicked: Observable<String> { get }
    var noteTextSubject: Observable<String?> { get }
    var siteSubject: Observable<String> { get }
    var isHiddenSimptoms: Observable<Bool> { get }
    // In
    var optionsTapped: PublishRelay<Void> { get }
    var crossTapped: PublishRelay<Void> { get }
    
    func getSymptomsCollection() -> UICollectionView
    func getFeelingsCollection() -> UICollectionView
}

final class TempDetailsVC: UIViewController {
    
    private enum TextConst {
        static let titleText: String = "Details"
        static let symptomsText: String = "Symptoms"
        static let feelingsText: String = "Your Feelings"
        static let addNotesButtonText: String = "Add notes..."
        static let dateTitleText: String = "Date"
        static let timeTitleText: String = "Time"
        static let siteTitleText: String = "Measure Site"
    }
    
    private enum LayoutConst {
        static let crossButtonSize: CGFloat = 48.0
        static let shareButtonSize: CGFloat = 48.0
    }
    
    private var feelingTitleLabelBottomConstraint: Constraint?
    
    private lazy var titleLabel: UILabel =
        .mediumTitleLabel(withText: TextConst.titleText, ofSize: 24.0)
    
    private lazy var crossButton: UIButton =
    UIButton(type: .system)
        .setImage(.crossIconBlack)
        .setBgColor(.appWhite)
        .setTintColor(.appBlack)
    
    private lazy var optionButton: UIButton =
    UIButton(type: .system)
        .setImage(.dotsIcon)
        .setBgColor(.appWhite)
        .setTintColor(.appBlack)
    
    private lazy var notesTextView: UIView =
    UIView()
        .bgColor(.appWhite)
    private lazy var notesLabel: UILabel =
        .regularTitleLabel(withText: "", ofSize: 15.0)
        .textAlignment(.left)
     
    private lazy var tempConditionTypeView: TempConditionTypeView =
    TempConditionTypeView()
    
    private lazy var dateTitleLabel: UILabel =
        .mediumTitleLabel(withText: TextConst.dateTitleText, ofSize: 18.0)
    private lazy var dateValueLabel: UILabel =
        .regularTitleLabel(withText: "", ofSize: 15.0)
    
    private lazy var timeTitleLabel: UILabel =
        .mediumTitleLabel(withText: TextConst.timeTitleText, ofSize: 18.0)
    private lazy var timeValueLabel: UILabel =
        .regularTitleLabel(withText: "", ofSize: 15.0)
    
    private lazy var siteTitleLabel: UILabel =
        .mediumTitleLabel(withText: TextConst.siteTitleText, ofSize: 18.0)
    private lazy var siteValueLabel: UILabel =
        .regularTitleLabel(withText: "", ofSize: 15.0)
    
    private lazy var symptomsTitleLabel: UILabel =
        .mediumTitleLabel(withText: TextConst.symptomsText, ofSize: 18.0)
    private lazy var symptomsCollection: UICollectionView =
    viewModel.getSymptomsCollection()
    
    private lazy var feelingTitleLabel: UILabel =
        .mediumTitleLabel(withText: TextConst.feelingsText, ofSize: 18.0)
    private lazy var feelingCollection: UICollectionView =
    viewModel.getFeelingsCollection()
    
    private var viewModel: TempDetailsViewModelProtocol
    
    private var bag = DisposeBag()
    
    init(viewModel: TempDetailsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        commonInit()
        setupSnapKitConstrains()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBg
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true,
                                                     animated: false)
    }
    
    private func bind() {
        viewModel.tempSubject
            .bind(to: tempConditionTypeView.temperatureSubject)
            .disposed(by: bag)
        viewModel.tempUnitSubject
            .bind(to: tempConditionTypeView.unitSubject)
            .disposed(by: bag)
        
        viewModel.datePicked
            .bind(to: dateValueLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.timePicked
            .bind(to: timeValueLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.siteSubject
            .bind(to: siteValueLabel.rx.text)
            .disposed(by: bag)
        viewModel.noteTextSubject
            .subscribe(onNext: { [weak self] text in
                guard let self, let text, !text.isEmpty else {
                    self?.notesTextView.isHidden = true
                    return
                }
                notesLabel.text = text
                notesTextView.isHidden = false
            })
            .disposed(by: bag)
        
        viewModel.isHiddenSimptoms
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isHidden in
                guard let self else { return }
                symptomsTitleLabel.isHidden = isHidden
                symptomsCollection.isHidden = isHidden
                let offset = isHidden ? 24.0 : 120.0
                feelingTitleLabelBottomConstraint?.update(offset: offset)
            })
            .disposed(by: bag)
        
        crossButton.rx.tap
            .bind(to: viewModel.crossTapped)
            .disposed(by: bag)
        optionButton.rx.tap
            .bind(to: viewModel.optionsTapped)
            .disposed(by: bag)

    }
    
}

//MARK: - Private
extension TempDetailsVC {
    
    func commonInit() {
        notesTextView.isHidden = true
        symptomsTitleLabel.isHidden = true
        notesTextView.isHidden = true
        view.addSubview(titleLabel)
        view.addSubview(crossButton)
        view.addSubview(tempConditionTypeView)
        view.addSubview(dateTitleLabel)
        view.addSubview(dateValueLabel)
        view.addSubview(timeTitleLabel)
        view.addSubview(timeValueLabel)
        view.addSubview(siteTitleLabel)
        view.addSubview(siteValueLabel)
        view.addSubview(symptomsTitleLabel)
        view.addSubview(symptomsCollection)
        view.addSubview(feelingTitleLabel)
        view.addSubview(feelingCollection)
        view.addSubview(notesTextView)
        view.addSubview(optionButton)
        notesTextView.radius = 8.0
        notesTextView.addSubview(notesLabel)
    }
    
    func setupSnapKitConstrains() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(71.0)
        }
        crossButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.size.equalTo(LayoutConst.crossButtonSize)
            make.left.equalToSuperview().inset(16.0)
        }
        crossButton.radius = LayoutConst.crossButtonSize / 2
        optionButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.size.equalTo(LayoutConst.shareButtonSize)
            make.right.equalToSuperview().inset(16.0)
        }
        optionButton.radius = LayoutConst.shareButtonSize / 2
        tempConditionTypeView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(32.0)
            make.horizontalEdges.equalToSuperview().inset(16.0)
        }
        dateTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16.0)
            make.top.equalTo(tempConditionTypeView.snp.bottom).offset(24.0)
        }
        dateValueLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16.0)
            make.top.equalTo(dateTitleLabel.snp.bottom).offset(18.0)
        }
        timeTitleLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(133)
            make.centerY.equalTo(dateTitleLabel.snp.centerY)
        }
        timeValueLabel.snp.makeConstraints { make in
            make.left.equalTo(timeTitleLabel.snp.left)
            make.centerY.equalTo(dateValueLabel.snp.centerY)
        }
        siteTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16.0)
            make.top.equalTo(timeValueLabel.snp.bottom).offset(24.0)
        }
        siteValueLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16.0)
            make.centerY.equalTo(siteTitleLabel.snp.centerY)
        }
        symptomsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(siteTitleLabel.snp.bottom).offset(24.0)
            make.left.equalToSuperview().inset(16.0)
        }
        symptomsCollection.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16.0)
            make.height.equalTo(80.0)
            make.top.equalTo(siteTitleLabel.snp.bottom).offset(62.0)
        }
        feelingTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16.0)
            feelingTitleLabelBottomConstraint =
            make.top.equalTo(siteTitleLabel.snp.bottom).offset(24).constraint
        }
        feelingCollection.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16.0)
            make.top.equalTo(feelingTitleLabel.snp.bottom).offset(16.0)
            make.height.equalTo(112.0)
        }
     
        notesTextView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16.0)
            make.top.equalTo(feelingCollection.snp.bottom).offset(8.0)
            make.height.equalTo(38.0)
        }
        notesLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(16.0)
        }
    }
    
}

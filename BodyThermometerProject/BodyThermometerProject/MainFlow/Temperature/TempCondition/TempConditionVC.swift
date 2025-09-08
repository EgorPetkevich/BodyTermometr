//
//  TempConditionVC.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 30.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol TempConditionViewModelProtocol {
    // Out
    var temperature: Observable<Double> { get }
    var tempUnit: Observable<TempUnit> { get }
    var datePicked: Observable<String> { get }
    var timePicked: Observable<String> { get }
    var noteTextSubject: Observable<String?> { get }
    // In
    var saveTapped: PublishRelay<Void> { get }
    var crossTapped: PublishRelay<Void> { get }
    var notesText: BehaviorRelay<String?> { get }
    var dateTapped: PublishRelay<Void> { get }
    var timeTapped: PublishRelay<Void> { get }
    var siteSelected :BehaviorRelay<MeasuringSiteUnit> { get }
    
    func viewDidLoad()
    func getSymptomsCollection() -> UICollectionView
    func getFeelingsCollection() -> UICollectionView
}

final class TempConditionVC: UIViewController {
    
    private enum TextConst {
        static let titleText: String = "Add Temperature"
        static let symptomsText: String = "Symptoms"
        static let feelingsText: String = "Your Feelings"
        static let addNotesButtonText: String = "Add notes..."
    }
    
    private enum LayoutConst {
        static let size: CGFloat = 48.0
    }
    
    private lazy var titleLabel: UILabel =
        .mediumTitleLabel(withText: TextConst.titleText, ofSize: 24.0)
    
    private lazy var crossButton: UIButton =
    UIButton(type: .system)
        .setImage(.crossIconBlack)
        .setBgColor(.appWhite)
        .setTintColor(.appBlack)
    
    private lazy var addNotesButton: UIButton =
    UIButton(type: .system)
        .setTitle(TextConst.addNotesButtonText)
        .setFont(.appSemiBoldFont(ofSize: 14.0))
        .setTintColor(.appBlack)
    
    private lazy var notesTextView: UIView =
    UIView()
        .bgColor(.appWhite)
    private lazy var notesLabel: UILabel =
        .regularTitleLabel(withText: "", ofSize: 15.0)
        .textAlignment(.left)
    private lazy var notesView: NotesView = NotesView()
    private lazy var notesViewCoverButton: UIButton = UIButton()
     
    private lazy var tempConditionTypeView: TempConditionTypeView =
    TempConditionTypeView()
    private lazy var dateTimePickView: DateTimePickView =
    DateTimePickView()
    private lazy var measureSiteView: MeasureSiteView =
    MeasureSiteView()
    
    private lazy var symptomsTitleLabel: UILabel =
        .mediumTitleLabel(withText: TextConst.symptomsText, ofSize: 18.0)
    private lazy var symptomsCollection: UICollectionView =
    viewModel.getSymptomsCollection()
    
    private lazy var feelingTitleLabel: UILabel =
        .mediumTitleLabel(withText: TextConst.feelingsText, ofSize: 18.0)
    private lazy var feelingCollection: UICollectionView =
    viewModel.getFeelingsCollection()
    
    private lazy var saveButton: SaveButtonView = SaveButtonView()
    
    private var viewModel: TempConditionViewModelProtocol
    
    private var bag = DisposeBag()
    
    init(viewModel: TempConditionViewModelProtocol) {
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
        viewModel.viewDidLoad()
    }
    
    private func bind() {
        viewModel.temperature
            .bind(to: tempConditionTypeView.temperatureSubject)
            .disposed(by: bag)
        viewModel.tempUnit
            .bind(to: tempConditionTypeView.unitSubject)
            .disposed(by: bag)
        
        dateTimePickView
            .dateTap
            .bind(to: viewModel.dateTapped)
            .disposed(by: bag)
        
        dateTimePickView
            .timeTap
            .bind(to: viewModel.timeTapped)
            .disposed(by: bag)
        
        viewModel.datePicked
            .bind(to: dateTimePickView.dateLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.timePicked
            .bind(to: dateTimePickView.timeLabel.rx.text)
            .disposed(by: bag)
        
        measureSiteView
            .selectedUnit
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(onNext: { [weak self] unit in
                guard let vm = self?.viewModel else { return }
                if vm.siteSelected.value != unit {
                    vm.siteSelected.accept(unit)
                }
            })
            .disposed(by: bag)

        viewModel.siteSelected
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: measureSiteView.selectedUnit)
            .disposed(by: bag)
        
        crossButton.rx.tap
            .bind(to: viewModel.crossTapped)
            .disposed(by: bag)
        saveButton.tap
            .bind(to: viewModel.saveTapped)
            .disposed(by: bag)
        
        addNotesButton.rx.tap
            .map { false }
            .bind(to: notesView.rx.isHidden)
            .disposed(by: bag)
        
        notesView.doneText
            .do(onNext: { [weak self] text in
                if text.isEmpty {
                    self?.notesTextView.isHidden = true
                    self?.addNotesButton.isHidden = false
                } else {
                    self?.notesLabel.text = text
                    self?.notesTextView.isHidden = false
                    self?.addNotesButton.isHidden = true
                }
            })
            .bind(to: viewModel.notesText)
            .disposed(by: bag)
        
        notesViewCoverButton.rx.tap
            .do(onNext: { [weak self] in
                self?.notesTextView.isHidden = true})
            .map { false }
            .bind(to: notesView.rx.isHidden)
            .disposed(by: bag)
        
        viewModel.noteTextSubject
            .subscribe(onNext: { [weak self] text in
                guard let self, let text, !text.isEmpty else { return }
                notesLabel.text = text
                notesView.text = text
                notesTextView.isHidden = false
                addNotesButton.isHidden = true
        })
        .disposed(by: bag)
        
    }
    
}

//MARK: - Private
extension TempConditionVC {
    
    func commonInit() {
        notesTextView.isHidden = true
        view.addSubview(titleLabel)
        view.addSubview(crossButton)
        view.addSubview(tempConditionTypeView)
        view.addSubview(dateTimePickView)
        view.addSubview(measureSiteView)
        view.addSubview(symptomsTitleLabel)
        view.addSubview(symptomsCollection)
        view.addSubview(feelingTitleLabel)
        view.addSubview(feelingCollection)
        view.addSubview(addNotesButton)
        view.addSubview(saveButton)
        view.addSubview(notesView)
        view.addSubview(notesTextView)
        notesTextView.radius = 8.0
        notesTextView.addSubview(notesLabel)
        notesTextView.addSubview(notesViewCoverButton)
        notesViewCoverButton.layer.zPosition = .greatestFiniteMagnitude
    }
    
    func setupSnapKitConstrains() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(71.0)
        }
        crossButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.size.equalTo(LayoutConst.size)
            make.left.equalTo(16.0)
        }
        crossButton.radius = LayoutConst.size / 2
        tempConditionTypeView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(32.0)
            make.horizontalEdges.equalToSuperview().inset(16.0)
        }
        dateTimePickView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16.0)
            make.top.equalTo(tempConditionTypeView.snp.bottom).offset(24.0)
        }
        measureSiteView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16.0)
            make.top.equalTo(dateTimePickView.snp.bottom).offset(24.0)
            make.height.equalTo(28.0)
        }
        symptomsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(measureSiteView.snp.bottom).offset(24.0)
            make.left.equalToSuperview().inset(16.0)
        }
        symptomsCollection.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16.0)
            make.height.equalTo(80.0)
            make.top.equalTo(measureSiteView.snp.bottom).offset(62.0)
        }
        feelingTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16.0)
            make.top.equalTo(symptomsCollection.snp.bottom).offset(24.0)
   
        }
        feelingCollection.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16.0)
            make.top.equalTo(feelingTitleLabel.snp.bottom).offset(16.0)
            make.height.equalTo(112.0)
        }
        addNotesButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(32.0)
            make.top.equalTo(feelingCollection.snp.bottom).offset(18.0)
        }
        saveButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16.0)
            make.top.equalTo(notesTextView.snp.bottom).offset(6.0)
        }
        notesView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
        notesViewCoverButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
}

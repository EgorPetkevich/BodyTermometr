//
//  MeasuringResultVC.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 27.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol MeasuringResultViewModelProtocol {
    // Out
    var bpm: Observable<Int> { get }
    func getCollection() -> UICollectionView
    // In
    var saveTapped: PublishRelay<Void> { get }
    var shareTapped: PublishRelay<Void> { get }
    var crossTapped: PublishRelay<Void> { get }
    var notesText: BehaviorRelay<String?> { get }
    
    func viewDidLoad()
}

final class MeasuringResultVC: UIViewController {
    
    private enum TextConst {
        static let titleText: String = "Measuring result"
        static let bpmText: String = "bpm"
        static let addNotesButtonText: String = "Add notes..."
        static let bpmExplanationText: String = "Normal ‘state’ normal Heart rate is 60 ~ 100 bmp"
        static let stateLabelText: String = "What state are your measuring in?"
    }
    
    private enum LayoutConst {
        static let crossButtonSize: CGFloat = 48.0
        static let shareButtonSize: CGFloat = 48.0
    }
    
    private var addNotesButtonBotomConstraint: Constraint?
    
    private lazy var titleLabel: UILabel =
        .mediumTitleLabel(withText: TextConst.titleText, ofSize: 24.0)
    private lazy var bpmExplanationLabel: UILabel =
        .regularTitleLabel(withText: TextConst.bpmExplanationText,
                           ofSize: 12.0,
                           color: .appGrey)
        .textAlignment(.center)
    
    private lazy var crossButton: UIButton =
    UIButton(type: .system)
        .setImage(.crossIconBlack)
        .setBgColor(.appWhite)
        .setTintColor(.appBlack)
    
    private lazy var shareButton: UIButton =
    UIButton(type: .system)
        .setImage(.sendIcon)
        .setBgColor(.appWhite)
        .setTintColor(.appBlack)
    
    private lazy var stateLabel: UILabel =
        .mediumTitleLabel(withText: TextConst.stateLabelText, ofSize: 18.0)
        .textAlignment(.left)
    
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
    
    private lazy var saveButton: SaveButtonView = SaveButtonView()
    private lazy var bpmResultView: BPMResultView = BPMResultView()
    private lazy var bpmStatusView: BPMStatusView = BPMStatusView()
    private lazy var bpmBarControl: BPMBarControl = BPMBarControl()
    private lazy var notesView: NotesView = NotesView()
    private lazy var activityView: UICollectionView = viewModel.getCollection()
    
    private var viewModel: MeasuringResultViewModelProtocol
    
    private var bag = DisposeBag()
    
    init(viewModel: MeasuringResultViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        commonInit()
        setupSnapKitConstraints()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true,
                                                     animated: false)
    }
    
    private func bind() {
        bindVM()
        bindButtons()
        bindViews()
    }
    
    private func bindVM() {
        viewModel.bpm
            .map { "\($0)" }
            .bind(to: bpmResultView.bmpValueLabel.rx.text)
            .disposed(by: bag)
        viewModel.bpm
            .bind(to: bpmStatusView.rx.bpmStatus)
            .disposed(by: bag)
        viewModel.bpm
            .bind(to: bpmBarControl.rx.bpm)
            .disposed(by: bag)
    }
    
    private func bindButtons() {
        shareButton.rx.tap
            .bind(to: viewModel.shareTapped)
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
    }
    
    private func bindViews() {
        notesView.doneText
            .do(onNext: { [weak self] text in
                if text.isEmpty {
                    self?.notesTextView.isHidden = true
                    self?.addNotesButtonBotomConstraint?.update(inset: 153.0)
                } else {
                    self?.notesTextView.isHidden = false
                    self?.notesLabel.text = text
                    self?.addNotesButtonBotomConstraint?.update(inset: 115.0)
                }
                
            })
            .bind(to: viewModel.notesText)
            .disposed(by: bag)
    }
    
}

//MARK: - Private
private extension MeasuringResultVC {
    
    func commonInit() {
        notesTextView.isHidden = true
        view.addSubview(titleLabel)
        view.addSubview(crossButton)
        view.addSubview(shareButton)
        view.addSubview(bpmResultView)
        view.addSubview(bpmStatusView)
        view.addSubview(bpmExplanationLabel)
        view.addSubview(bpmBarControl)
        view.addSubview(stateLabel)
        view.addSubview(activityView)
        view.addSubview(addNotesButton)
        view.addSubview(saveButton)
        view.addSubview(notesView)
        view.addSubview(notesTextView)
        notesTextView.radius = 8.0
        notesTextView.addSubview(notesLabel)
        notesView.layer.zPosition = .greatestFiniteMagnitude
    }
    
    func setupSnapKitConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(17.0)
        }
        crossButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.size.equalTo(LayoutConst.crossButtonSize)
            make.left.equalToSuperview().inset(16.0)
        }
        crossButton.radius = LayoutConst.crossButtonSize / 2
        shareButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.size.equalTo(LayoutConst.shareButtonSize)
            make.right.equalToSuperview().inset(16.0)
        }
        shareButton.radius = LayoutConst.shareButtonSize / 2
        bpmResultView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(84.0)
            make.top.equalTo(titleLabel.snp.bottom).offset(20.0)
        }
        bpmStatusView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(bpmResultView.snp.bottom).offset(8.0)
        }
        bpmExplanationLabel.snp.makeConstraints { make in
            make.top.equalTo(bpmStatusView.snp.bottom).offset(8.0)
            make.horizontalEdges.equalToSuperview()
        }
        bpmBarControl.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(18.0)
            make.top.equalTo(bpmExplanationLabel.snp.bottom).offset(16.0)
        }
        stateLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16.0)
            make.top.equalTo(bpmBarControl.snp.bottom).offset(28.0)
        }
        activityView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16.0)
            make.top.equalTo(stateLabel.snp.bottom).offset(16.0)
            make.height.equalTo(232)
        }
        addNotesButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(32.0)
            addNotesButtonBotomConstraint =
            make.bottom.equalToSuperview().inset(153.0).constraint
        }
        saveButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16.0)
            make.bottom.equalToSuperview().inset(47.0)
        }
        notesView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        notesTextView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16.0)
            make.bottom.equalTo(addNotesButton.snp.top).offset(-8.0)
            make.height.equalTo(38.0)
        }
        notesLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(16.0)
        }
    }
    
}

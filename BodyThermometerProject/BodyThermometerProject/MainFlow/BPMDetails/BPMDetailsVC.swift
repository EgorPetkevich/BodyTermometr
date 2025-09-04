//
//  BPMDetailsVC.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 4.09.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol BPMDetailsViewModelProtocol {
    // Out
    var bpm: Observable<Int> { get }
    var noteText: Observable<String?> { get }
    func getCollection() -> UICollectionView
    // In
    var optionTapped: PublishRelay<Void> { get }
    var crossTapped: PublishRelay<Void> { get }
}

final class BPMDetailsVC: UIViewController {
    
    private enum TextConst {
        static let titleText: String = "Details"
        static let bpmExplanationText: String = "Normal ‘state’ normal Heart rate is 60 ~ 100 bmp"
        static let stateLabelText: String = "Your state"
    }
    
    private enum LayoutConst {
        static let crossButtonSize: CGFloat = 48.0
        static let shareButtonSize: CGFloat = 48.0
    }
    
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
    
    private lazy var optionButton: UIButton =
    UIButton(type: .system)
        .setImage(.dotsIcon)
        .setBgColor(.appWhite)
        .setTintColor(.appBlack)
    
    private lazy var stateLabel: UILabel =
        .mediumTitleLabel(withText: TextConst.stateLabelText, ofSize: 18.0)
        .textAlignment(.left)
    
    private lazy var notesTextView: UIView =
    UIView()
        .bgColor(.appWhite)
    private lazy var notesLabel: UILabel =
        .regularTitleLabel(withText: "", ofSize: 15.0)
        .textAlignment(.left)
    
    private lazy var bpmResultView: BPMResultView = BPMResultView()
    private lazy var bpmStatusView: BPMStatusView = BPMStatusView()
    private lazy var bpmBarControl: BPMBarControl = BPMBarControl()
    private lazy var activityView: UICollectionView = viewModel.getCollection()
    
    private var viewModel: BPMDetailsViewModelProtocol
    
    private var bag = DisposeBag()
    
    init(viewModel: BPMDetailsViewModelProtocol) {
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true,
                                                     animated: false)
    }
    
    private func bind() {
        bindVM()
        bindButtons()
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
        viewModel.noteText
            .compactMap { $0 }
            .do(onNext: { [weak self] _ in
                self?.notesTextView.isHidden = false
            })
            .bind(to: notesLabel.rx.text)
            .disposed(by: bag)
    }
    
    private func bindButtons() {
        optionButton.rx.tap
            .bind(to: viewModel.optionTapped)
            .disposed(by: bag)
        crossButton.rx.tap
            .bind(to: viewModel.crossTapped)
            .disposed(by: bag)
    }
    
}

//MARK: - Private
private extension BPMDetailsVC {
    
    func commonInit() {
        notesTextView.isHidden = true
        view.addSubview(titleLabel)
        view.addSubview(crossButton)
        view.addSubview(optionButton)
        view.addSubview(bpmResultView)
        view.addSubview(bpmStatusView)
        view.addSubview(bpmExplanationLabel)
        view.addSubview(bpmBarControl)
        view.addSubview(stateLabel)
        view.addSubview(activityView)
        view.addSubview(notesTextView)
        notesTextView.radius = 8.0
        notesTextView.addSubview(notesLabel)
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
        optionButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.size.equalTo(LayoutConst.shareButtonSize)
            make.right.equalToSuperview().inset(16.0)
        }
        optionButton.radius = LayoutConst.shareButtonSize / 2
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
            make.height.equalTo(112)
        }
        notesTextView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16.0)
            make.top.equalTo(activityView.snp.bottom).offset(16.0)
            make.height.equalTo(38.0)
        }
        notesLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(16.0)
        }
    }
    
}

//
//  MeasuringVC.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 26.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Lottie

protocol MeasuringViewModelProtocol {
    // Out
    var pulseText: Observable<String> { get }
    var progress: Observable<Double> { get }
    var measurementStarted: Observable<Bool> { get }
    // In
    var crossButtonTapped: PublishRelay<Void> { get }
    var viewDidAppear: PublishRelay<Void> { get }
    var viewWillAppear: PublishRelay<Void> { get }
    var viewWillDisappear: PublishRelay<Void> { get }
}

final class MeasuringVC: UIViewController {

    private enum TextConst {
        static let titleText = "Measuring"
        static let subTitleText = "Make sure to fully cover the camera \nfor the entire measurement."
        static let measuringSubTitleText = "Measuring, please keep still"
    }

    private lazy var crossButton: UIButton =
    UIButton(type: .system)
        .setImage(.crossIconBlack)
        .setBgColor(.appWhite)
        .setTintColor(.appBlack)

    private lazy var titleLabel: UILabel =
        .mediumTitleLabel(withText: TextConst.titleText, ofSize: 24.0)
    
    private lazy var subTitleLabel: UILabel =
        .mediumTitleLabel(withText: TextConst.subTitleText, ofSize: 18.0)
        .textAlignment(.center)
        .numOfLines(2)
    private lazy var bpmAnimationView: LottieAnimationView =
    LottieAnimationView(name: "bpm_animation")

    private let progressView = CircularProgressView()
 
    private let bpmView: BPMView = BPMView()

    private let bag = DisposeBag()
    private let viewModel: MeasuringViewModelProtocol

    init(viewModel: MeasuringViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        commonInit()
        setupSnapKitConstraints()
        bind()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func bind() {
        viewModel.pulseText
            .subscribe(onNext: { [weak self] p in
                self?.bpmView.bpmValueLabel.text = p
            })
            .disposed(by: bag)
        viewModel.progress
            .subscribe(onNext: { [weak self] p in self?.progressView.setProgress(p) })
            .disposed(by: bag)
        
        viewModel.measurementStarted
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] started in
                guard let self = self else { return }
                subTitleLabel.text =
                started ? TextConst.measuringSubTitleText : TextConst.subTitleText
                bpmAnimationView.isHidden = !started
                if started {
                    if self.bpmAnimationView.isAnimationPlaying == false {
                        self.bpmAnimationView.play()
                    }
                } else {
                    self.bpmAnimationView.stop()
                }
            })
            .disposed(by: bag)
        
        crossButton.rx.tap
            .bind(to: viewModel.crossButtonTapped)
            .disposed(by: bag)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBg
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true,
                                                     animated: false)
        viewModel.viewWillAppear.accept(())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.viewDidAppear.accept(())
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bpmAnimationView.stop()
        viewModel.viewWillDisappear.accept(())
    }

}

//MARK: - Private
private extension MeasuringVC {
    
    private func commonInit() {
        view.addSubview(titleLabel)
        view.addSubview(subTitleLabel)
        view.addSubview(bpmView)
        view.addSubview(progressView)
        view.addSubview(crossButton)
        view.addSubview(bpmAnimationView)
        bpmAnimationView.isHidden = true
        bpmAnimationView.loopMode = .loop
    }
    
    func setupSnapKitConstraints() {
        crossButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16.0)
            make.top.equalToSuperview().inset(62.0)
            make.size.equalTo(48.0)
        }
        crossButton.radius = 24.0
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(17.0)
            make.centerX.equalToSuperview()
        }
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(158.0)
            make.centerX.equalToSuperview()
        }
        bpmView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(200)
        }
        progressView.snp.makeConstraints { make in
            make.center.equalTo(bpmView)
            make.width.height.equalTo(230.0)
        }
        bpmAnimationView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(84)
            make.horizontalEdges.equalToSuperview()
        }

    }
    
}

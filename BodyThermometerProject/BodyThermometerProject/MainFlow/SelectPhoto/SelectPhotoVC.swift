//
//  SelectPhotoVC.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 21.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol SelectPhotoViewModelProtocol {
    //Out
    //In
    var closeTapped: PublishSubject<Void> { get }
    var uploadFromGalleryTapped: PublishSubject<Void> { get }
    var openCameraTapped: PublishSubject<Void> { get }
}

final class SelectPhotoVC: UIViewController {
    
    private enum TextConst {
        static let titleText: String = "Select Photo"
        static let closeButtonText: String = "Close"
        static let uploadFromGalleryButtonText: String = "Upload from Gallery"
        static let openCameraButtonText: String = "Open Camera"
    }
    
    private lazy var titleLabel: UILabel =
        .mediumTitleLabel(withText: TextConst.titleText, ofSize: 24.0)
    
    private lazy var closeButton: UIButton =
    UIButton(type: .system)
        .setTitle(TextConst.closeButtonText)
        .setTintColor(.appGrey)
    
    private lazy var uploadFromGalleryButtonView: SelectPhotoButtonView =
    SelectPhotoButtonView(icon: .galleryIconBlack,
                          titleText: TextConst.uploadFromGalleryButtonText,
                          type: .black)
    
    private lazy var openCameraButtonView: SelectPhotoButtonView =
    SelectPhotoButtonView(icon: .cameraIconWhite,
                          titleText: TextConst.openCameraButtonText,
                          type: .white)
    
    private var viewModel: SelectPhotoViewModelProtocol
    
    private var bag = DisposeBag()
    
    init(viewModel: SelectPhotoViewModelProtocol) {
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
        view.layer.cornerRadius = 32
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private func bind() {
        closeButton.rx.tap
            .bind(to: viewModel.closeTapped)
            .disposed(by: bag)
        
        uploadFromGalleryButtonView.tap
            .bind(to: viewModel.uploadFromGalleryTapped)
            .disposed(by: bag)
        
        openCameraButtonView.tap
            .bind(to: viewModel.openCameraTapped)
            .disposed(by: bag)
    }
    
}

//MARK: - Private
extension SelectPhotoVC {
    
    func commonInit() {
        self.view.addSubview(titleLabel)
        self.view.addSubview(closeButton)
        self.view.addSubview(uploadFromGalleryButtonView)
        self.view.addSubview(openCameraButtonView)
    }
    
    func setupSnapKitConstraints() {
        closeButton.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(24.0)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(38.0)
            make.centerX.equalToSuperview()
        }
        uploadFromGalleryButtonView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(32.0)
            make.horizontalEdges.equalToSuperview().inset(16.0)
        }
        openCameraButtonView.snp.makeConstraints { make in
            make.top.equalTo(uploadFromGalleryButtonView.snp.bottom).offset(16.0)
            make.horizontalEdges.equalToSuperview().inset(16.0)
        }
    }
    
}

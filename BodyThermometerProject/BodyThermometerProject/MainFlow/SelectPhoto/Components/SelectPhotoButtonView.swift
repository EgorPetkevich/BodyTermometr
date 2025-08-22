//
//  SelectPhotoButtonView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 21.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class SelectPhotoButtonView: UIView {
    
    enum SelectPhotoButtonStyle {
        case black
        case white
    }
    
    private enum LayoutConst {
        static let height: CGFloat = 64.0
        static let iconViewSize: CGFloat = 44.0
    }
    
    private var type: SelectPhotoButtonStyle
    
    private lazy var titleLabel: UILabel =
        .semiBoldTitleLabel(withText: "", ofSize: 14.0)
    
    private lazy var iconView: UIView = UIView()
    private lazy var iconImageView: UIImageView = UIImageView()
    private lazy var arrowIconImageView: UIImageView = UIImageView()
 
    private lazy var coverButton: UIButton = UIButton()
    
    var tap: Observable<Void> {
        coverButton.rx.tap.asObservable()
    }
    
    private lazy var bag = DisposeBag()
    
    init(icon: UIImage, titleText: String, type: SelectPhotoButtonStyle) {
        self.type = type
        super.init(frame: .zero)
        self.titleLabel.text = titleText
        self.iconImageView.image = icon
        commonInit()
        setupSnapKitConstraints()
        setupStyle(with: type)
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        coverButton.rx.controlEvent(.touchDown)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.alpha = 0.7
                }
            })
            .disposed(by: bag)
        
        coverButton.rx.controlEvent(
            [.touchUpInside,
            .touchUpOutside,
            .touchCancel])
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.alpha = 1.0
                }
            })
            .disposed(by: bag)
    }
    
}

//MARK: - Private
private extension SelectPhotoButtonView {
    
    func commonInit() {
        self.addSubview(iconView)
        iconView.addSubview(iconImageView)
        self.addSubview(titleLabel)
        self.addSubview(arrowIconImageView)
        self.addSubview(coverButton)
        coverButton.layer.zPosition = .greatestFiniteMagnitude
    }
    
    func setupSnapKitConstraints() {
        self.snp.makeConstraints { make in
            make.height.equalTo(LayoutConst.height)
        }
        self.radius = LayoutConst.height / 2
        iconView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(16.0)
            make.size.equalTo(LayoutConst.iconViewSize)
        }
        iconView.radius = LayoutConst.iconViewSize / 2
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(68.0)
        }
        arrowIconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(10.0)
        }
        coverButton.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
    }
    
    func setupStyle(with type: SelectPhotoButtonStyle) {
        self.backgroundColor =  type == .black ? .appBlack : .appWhite
        iconView.backgroundColor =  type == .black ? .appWhite : .appBlack
        titleLabel.textColor = type == .black ? .appWhite : .appBlack
        arrowIconImageView.image =
        type == .black ? .arrowIconRightWhite : .arrowIconRightBlack

    }
    
}

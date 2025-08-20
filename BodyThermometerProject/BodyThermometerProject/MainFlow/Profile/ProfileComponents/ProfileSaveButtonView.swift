//
//  ProfileSaveButtonView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 20.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class ProfileSaveButtonView: UIButton {
    
    private enum TextConst {
        static let saveText = "Save"
    }
    
    private enum LayoutConst {
        static let height: CGFloat = 64.0
    }
    
    private lazy var saveLabel: UILabel =
        .semiBoldTitleLabel(withText: TextConst.saveText, ofSize: 14.0)
    
    private lazy var coverButton: UIButton = UIButton()
    
    var onTap: Observable<Void> {
        coverButton.rx.tap.asObservable()
    }
    
    private var bag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupSnapKitConstraints()
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
        coverButton.rx
            .controlEvent([.touchUpInside,
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
private extension ProfileSaveButtonView {
    
    func commonInit() {
        self.backgroundColor = .appButton
        //add subs
        self.addSubview(saveLabel)
        self.addSubview(coverButton)
        coverButton.layer.zPosition = .greatestFiniteMagnitude
    }
    
    func setupSnapKitConstraints() {
        self.snp.makeConstraints { make in
            make.height.equalTo(LayoutConst.height)
        }
        self.radius = LayoutConst.height / 2.0
        saveLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        coverButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}

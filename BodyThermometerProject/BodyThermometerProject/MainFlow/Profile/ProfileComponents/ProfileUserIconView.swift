//
//  ProfileUserIconView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 20.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class ProfileUserIconView: UIView {
    
    private enum LayoutConst {
        static let size: CGSize = .init(width: 100.0, height: 100.0)
    }
    
    private lazy var iconImageView: UIImageView = UIImageView()
    private lazy var coverButton: UIButton = UIButton()
    
    var tap: Observable<Void> {
        coverButton.rx.tap.asObservable()
    }
    
    var icon: UIImage? {
        get { iconImageView.image }
        set { iconImageView.image = newValue }
    }
    
    private let bag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupSnapkitConstraints()
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
private extension ProfileUserIconView {

    func commonInit() {
        self.backgroundColor = .appWhite
        self.addSubview(iconImageView)
        self.addSubview(coverButton)
        coverButton.layer.zPosition = .greatestFiniteMagnitude
    }
    
    func setupSnapkitConstraints() {
        self.snp.makeConstraints { make in
            make.size.equalTo(LayoutConst.size)
        }
        self.radius = LayoutConst.size.width / 2
        iconImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        coverButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}


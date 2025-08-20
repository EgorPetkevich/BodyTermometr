//
//  EnableTrialView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 15.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class EnableTrialView: UIView {
    
    private enum LayoutConst {
        static let height: CGFloat = 56.0
    }
    
    private enum TextConst {
        static let titleText: String = "Enable 3-day free trial"
    }
    
    var isTrialRelay: BehaviorRelay<Bool> = .init(value: false)
    
    private lazy var titleLabel: UILabel =
        .regularTitleLabel(withText: TextConst.titleText,
                           ofSize: 15.0,
                           color: .appBlack.withAlphaComponent(0.6))
    
    private lazy var checkImageView: UIImageView =
    UIImageView(image: .paywallCheckbox)
    
    private lazy var coverButton: UIButton = UIButton()
    
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
        coverButton.rx.tap
            .scan(isTrialRelay.value) { previous, _ in !previous }
            .do(onNext: isTrialRelay.accept)
            .map { $0 ? UIImage.paywallCheckboxFill : UIImage.paywallCheckbox }
            .bind(to: checkImageView.rx.image)
            .disposed(by: bag)
    }
    
}

//MARK: - Private
private extension EnableTrialView {
    
    func commonInit() {
        self.backgroundColor = .appLightGrey
        self.radius = 16.0
        addSubview(titleLabel)
        addSubview(checkImageView)
        addSubview(coverButton)
        coverButton.layer.zPosition = .greatestFiniteMagnitude
    }
    
    func setupSnapKitConstraints() {
        self.snp.makeConstraints { make in
            make.height.equalTo(LayoutConst.height)
        }
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(16.0)
        }
        checkImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(18.0)
        }
        coverButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}

//
//  AttentionAlertVC.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 6.09.25.
//

import UIKit
import RxSwift
import RxCocoa

final class AttentionAlertVC: UIViewController {
    // OUT
    let done = PublishRelay<Bool>() // передаём состояние чекбокса

    private let bag = DisposeBag()

    private let dimView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterialDark))
    private let container = UIView()
    private let iconView = UIImageView(image: .attentionIcon)
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let checkboxButton = UIButton()
    private let checkboxLabel = UILabel()
    private let doneButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        bind()
    }

    private func setupUI() {
        modalPresentationStyle = .overFullScreen
        view.backgroundColor = .clear

        dimView.alpha = 0.95
        view.addSubview(dimView)
        dimView.snp.makeConstraints { $0.edges.equalToSuperview() }

        container.backgroundColor = .appWhite
        container.layer.cornerRadius = 22
        container.layer.masksToBounds = true
        view.addSubview(container)

        iconView.tintColor = .systemRed
        iconView.contentMode = .scaleAspectFit
        titleLabel.text = "Attention"
        titleLabel.font = .appMediumFont(ofSize: 24)
        titleLabel.textAlignment = .center

        messageLabel.text = """
        The information in this app is for informational purposes only and should \
        not be used as a replacement for professional medical guidance.
        """
        messageLabel.font = .appRegularFont(ofSize: 15)
        messageLabel.textColor = .appGrey
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center

        checkboxButton.setImage(.checkboxIcon, for: .normal)
        checkboxButton.setImage(.checkboxFillIcon, for: .selected)
      

        checkboxLabel.text = "Don’t show again"
        checkboxLabel.font = .appRegularFont(ofSize: 16)
        checkboxLabel.textColor = .appBlack

        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = .appSemiBoldFont(ofSize: 14)
        doneButton.backgroundColor = .appButton
        doneButton.tintColor = .appBlack
        doneButton.layer.cornerRadius = 52 / 2

        [iconView, titleLabel, messageLabel, checkboxButton, checkboxLabel, doneButton]
            .forEach { container.addSubview($0) }
    }

    private func setupLayout() {
        container.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(30)
        }

        iconView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 70, height: 70))
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(24)
        }

        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(28)
        }

        let checkboxStack = UIStackView(arrangedSubviews: [checkboxButton, checkboxLabel])
        checkboxStack.axis = .horizontal
        checkboxStack.spacing = 8
        checkboxStack.alignment = .center
        container.addSubview(checkboxStack)

        checkboxStack.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(25)
            make.centerX.equalToSuperview()
        }
        checkboxButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 28, height: 28))
        }

        doneButton.snp.makeConstraints { make in
            make.top.equalTo(checkboxStack.snp.bottom).offset(42)
            make.left.right.equalToSuperview().inset(65)
            make.height.equalTo(52)
            make.bottom.equalToSuperview().inset(26)
        }
    }

    private func bind() {
        let labelTap = UITapGestureRecognizer()
        checkboxLabel.isUserInteractionEnabled = true
        checkboxLabel.addGestureRecognizer(labelTap)

        Observable.merge(
            checkboxButton.rx.tap.asObservable(),
            labelTap.rx.event.map { _ in () }
        )
        .subscribe(onNext: { [weak self] in
            self?.checkboxButton.isSelected.toggle()
        })
        .disposed(by: bag)

        doneButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let self else { return }
                self.done.accept(self.checkboxButton.isSelected)
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: bag)
    }
}

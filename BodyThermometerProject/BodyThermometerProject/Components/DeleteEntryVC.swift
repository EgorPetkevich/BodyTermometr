//
//  DeleteEntryVC.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 7.09.25.
//

import UIKit
import RxSwift
import RxCocoa

final class DeleteEntryVC: UIViewController {
    // OUT
    let deleteTapped = PublishRelay<Void>()
    private let bag = DisposeBag()

    private let dimView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterialDark))
    private let container = UIView()
    private let iconView = UIImageView(image: .binIcon)
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let deleteButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)

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

        iconView.contentMode = .scaleAspectFit
        titleLabel.text = "Delete This Entry"
        titleLabel.font = .appMediumFont(ofSize: 24)
        titleLabel.textAlignment = .center

        messageLabel.text = """
        This action will permanently remove this \ndata from your history.
        """
        messageLabel.font = .appRegularFont(ofSize: 15)
        messageLabel.textColor = .appGrey
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center

        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.titleLabel?.font = .appSemiBoldFont(ofSize: 14)
        deleteButton.backgroundColor = .appWhite
        deleteButton.tintColor = .appBlack
        deleteButton.layer.borderWidth = 1
        deleteButton.layer.borderColor = UIColor.appButton.cgColor
        deleteButton.layer.cornerRadius = 52 / 2
        
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = .appSemiBoldFont(ofSize: 14)
        cancelButton.backgroundColor = .appButton
        cancelButton.tintColor = .appBlack
        cancelButton.layer.cornerRadius = 52 / 2

        [iconView, titleLabel, messageLabel, deleteButton, cancelButton]
            .forEach { container.addSubview($0) }
    }

    private func setupLayout() {
        container.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(30)
        }

        iconView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(28)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 70, height: 70))
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(24)
        }

        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(28)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(36.0)
            make.height.equalTo(52)
            make.left.right.equalToSuperview().inset(65)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(deleteButton.snp.bottom).offset(16.0)
            make.left.right.equalToSuperview().inset(65)
            make.height.equalTo(52)
            make.bottom.equalToSuperview().inset(26)
        }
    }

    private func bind() {
        deleteButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                deleteTapped.accept(())
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: bag)
        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: bag)
    }
}

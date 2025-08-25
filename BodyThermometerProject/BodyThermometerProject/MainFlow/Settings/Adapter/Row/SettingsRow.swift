//
//  SettingsRow.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 25.08.25.
//

import UIKit
import SnapKit

protocol SettingsRowProtocol {
    var titleText: String { get }
    var iconImage: UIImage { get }
}

final class SettingsRow: UITableViewCell {
    
    private let titleLabel: UILabel =
        .regularTitleLabel(withText: "", ofSize: 15.0)
    
    private let iconImageView: UIImageView = UIImageView()
    
    private let arrowImageView: UIImageView =
    UIImageView(image: .arrowIconRightBlack)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
        setupSnapkitConstraints()
        setupSelectedBackgroundView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectedBackgroundView?.center.y = contentView.center.y
    }
    
    func configure(_ item: SettingsRowProtocol) {
        titleLabel.text = item.titleText
        iconImageView.image = item.iconImage
    }
    
}

//MARK: - Private
private extension SettingsRow {
    
    func commonInit() {
        contentView.backgroundColor = .appWhite
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(arrowImageView)
    }
    
    func setupSnapkitConstraints() {
        iconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(16.0)
        }
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(iconImageView.snp.right).offset(8.0)
        }
        arrowImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(16.0)
        }
    }
    
    func setupSelectedBackgroundView() {
        let bgColorView = UIView()
        bgColorView.backgroundColor = .appWhite.withAlphaComponent(0.7)
        selectedBackgroundView = bgColorView
        
        selectedBackgroundView?.layer.masksToBounds = true
        selectedBackgroundView?.layer.zPosition =
        CGFloat(Float.greatestFiniteMagnitude)
    }
    
    
    
}

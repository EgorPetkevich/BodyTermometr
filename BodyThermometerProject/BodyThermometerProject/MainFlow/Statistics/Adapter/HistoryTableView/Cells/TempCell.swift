//
//  TempCell.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 2.09.25.
//

import UIKit
import SnapKit

final class TempCell: UITableViewCell {
    
    private enum TextConst {
        static let titleText = "Body Temperature"
    }
    
    private enum LayoutConst {
        static let iconImageViewSize: CGFloat = 48.0
        static let statusViewHeight: CGFloat = 25.0
    }
    
    private lazy var titleLabel: UILabel =
        .regularTitleLabel(withText: TextConst.titleText,
                           ofSize: 15.0,
                           color: .appGrey)
    
    private lazy var iconView: UIView = UIView()
        .bgColor(.appBlack)
    private lazy var iconImageView: UIImageView =
    UIImageView(image: .statTemperature)
    
    private lazy var tempLabel: UILabel =
        .mediumTitleLabel(withText: "", ofSize: 18.0)
    
    private lazy var dateLabel: UILabel =
        .regularTitleLabel(withText: "",
                           ofSize: 12.0,
                           color: .appGrey)
    
    private lazy var statusView: UIView = UIView()
    private lazy var statusLabel: UILabel =
        .semiBoldTitleLabel(withText: "",
                            ofSize: 14.0,
                            color: .appWhite)
    
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
        contentView.frame = contentView.frame
            .inset(by: UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0))
    }
    
    func configure(_ dto: TempModelDTO, unit: TempUnit) {
        let celsiusValue = Double(dto.temp)
        let displayValue: Double
        let unitSuffix: String
        switch unit {
        case .c:
            displayValue = celsiusValue
            unitSuffix = "ºC"
        case .f:
            displayValue = celsiusValue * 9.0 / 5.0 + 32.0
            unitSuffix = " F"
        }
        tempLabel.text = String(format: "%.1f%@", displayValue, unitSuffix)

        dateLabel.text = dto.date.toDisplayString()

        statusView.backgroundColor = TempPoint.getColor(from: celsiusValue)
        statusLabel.text = TempPoint.getDescription(from: celsiusValue)
    }
    
}

//MARK: - Private
private extension TempCell {
    
    func commonInit() {
        contentView.backgroundColor = .appLightGrey
        contentView.addSubview(titleLabel)
        contentView.addSubview(iconImageView)
        contentView.addSubview(tempLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(statusView)
        contentView.addSubview(iconView)
        iconView.addSubview(iconImageView)
        statusView.addSubview(statusLabel)
    }
    
    func setupSnapkitConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10.5)
            make.left.equalToSuperview().inset(61.0)
        }
        iconView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(8)
            make.size.equalTo(LayoutConst.iconImageViewSize)
        }
        iconView.radius = LayoutConst.iconImageViewSize / 2
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        tempLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(3.0)
            make.left.equalTo(titleLabel.snp.left)
        }
        statusView.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.right.equalToSuperview().inset(12.0)
            make.height.equalTo(LayoutConst.statusViewHeight)
        }
        statusView.radius = LayoutConst.statusViewHeight / 2
        statusLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(8.0)
        }
        dateLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(13.0)
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

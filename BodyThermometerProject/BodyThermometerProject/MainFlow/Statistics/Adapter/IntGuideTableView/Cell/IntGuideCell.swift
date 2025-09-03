//
//  IntGuideCell.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 3.09.25.
//

import UIKit
import SnapKit

protocol IntGuideCellProtocol {
    var statusColor: UIColor { get }
    var statusText: String { get }
    func valueText(_ unit: TempUnit?) -> String
}

final class IntGuideCell: UITableViewCell {
    
    private lazy var statusView: UIView = UIView()
    
    private lazy var statusLabel: UILabel =
        .regularTitleLabel(withText: "", ofSize: 15.0)
    
    private lazy var valueLabel: UILabel =
        .regularTitleLabel(withText: "", ofSize: 15.0)
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
        setupSnapkitConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with subject: IntGuideCellProtocol,
                   tepmUnit: TempUnit? = nil) {
        statusView.backgroundColor = subject.statusColor
        statusLabel.text = subject.statusText
        valueLabel.text = subject.valueText(tepmUnit)
    }
    
}

//MARK: - Private
private extension IntGuideCell {
    
    func commonInit() {
        contentView.backgroundColor = .clear
        contentView.addSubview(statusView)
        contentView.addSubview(statusLabel)
        contentView.addSubview(valueLabel)
    }
    
    func setupSnapkitConstraints() {
        statusView.snp.makeConstraints { make in
            make.size.equalTo(20.0)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
        }
        statusView.radius = 10.0
        statusLabel.snp.makeConstraints { make in
            make.left.equalTo(statusView.snp.right).offset(8.0)
            make.centerY.equalToSuperview()
        }
        valueLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
        }
        
    }
    
}


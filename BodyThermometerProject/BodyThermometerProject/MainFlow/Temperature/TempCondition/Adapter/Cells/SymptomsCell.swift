//
//  SymptomsCell.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 31.08.25.
//

import UIKit
import SnapKit

final class SymptomChipCell: UICollectionViewCell {
    private let title = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.appBlack.cgColor
        contentView.backgroundColor = .clear

        title.font = .appRegularFont(ofSize: 15.0)
        title.textColor = .appBlack

        contentView.addSubview(title)

        title.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.verticalEdges.equalToSuperview().inset(8.0)
        }
        title.setContentHuggingPriority(.required, for: .horizontal)
        title.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(_ text: String, selected: Bool) {
        title.text = text
        applySelection(selected)
    }

    override var isSelected: Bool {
        didSet { applySelection(isSelected) }
    }

    private func applySelection(_ selected: Bool) {
        contentView.backgroundColor = selected ? .appBlack : .clear
        title.textColor = selected ? .appWhite : .appBlack
    }
}

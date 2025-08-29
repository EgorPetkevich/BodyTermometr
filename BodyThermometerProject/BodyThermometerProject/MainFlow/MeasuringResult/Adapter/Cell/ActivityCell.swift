//
//  ActivityCell.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 28.08.25.
//
import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class ActivityCell: UICollectionViewCell {
    
    private lazy var imageView: UIImageView = UIImageView()
        .contentMode(.scaleAspectFit)
    
    private lazy var title: UILabel =
        .regularTitleLabel(withText: "", ofSize: 15.0)

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupSnapKitConstraints()
    }
    
    required init?(coder: NSCoder) { fatalError() }

    func configure(with model: Activity) {
        imageView.image = model.image
        title.text = model.title
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                title.textColor = .appButton
                contentView.layer.borderWidth = 2
                contentView.layer.borderColor = UIColor.appButton.cgColor
            } else {
                title.textColor = .appBlack
                contentView.layer.borderWidth = 0
                contentView.layer.borderColor = nil
            }
        }
    }
}

//MARK: - Private
private extension ActivityCell {
    
    func commonInit() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 24
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(imageView)
        contentView.addSubview(title)
    }
    
    func setupSnapKitConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.centerX.equalToSuperview()
            make.size.equalTo(70)
            
        }
        title.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(8)
        }
    }
    
}

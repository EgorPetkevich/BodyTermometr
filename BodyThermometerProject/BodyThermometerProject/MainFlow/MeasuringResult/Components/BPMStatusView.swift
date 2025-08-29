//
//  BPMStatusView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 28.08.25.
//

import UIKit
import SnapKit

final class BPMStatusView: UIView {

    private enum LayoutConst {
        static let size: CGSize = .init(width: 105.0, height: 54.0)
    }
    
    var bmpStatusLabel: UILabel =
        .mediumTitleLabel(withText: "", ofSize: 18.0, color: .appWhite)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupSnapKitConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//MARK: - Private
private extension BPMStatusView {
    func commonInit() {
        addSubview(bmpStatusLabel)
    }
    
    func setupSnapKitConstraints() {
        self.snp.makeConstraints { make in
            make.size.equalTo(LayoutConst.size)
        }
        self.radius = LayoutConst.size.height / 2
        bmpStatusLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

}


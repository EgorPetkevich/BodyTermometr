//
//  BPMResultView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 27.08.25.
//

import UIKit
import SnapKit

final class BPMResultView: UIView {
    
    private enum TextConst {
        static let bpmText: String = "bpm"
    }

    private enum LayoutConst {
        static let height: CGFloat = 84.0
    }
    
    var bmpValueLabel: UILabel =
        .mediumTitleLabel(withText: "00", ofSize: 70.0)
    
    private lazy var centerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [bmpValueLabel, vertivalStack])
        stack.axis = .horizontal
        stack.spacing = 22.0
        stack.alignment = .center
        return stack
    }()
    
    private lazy var vertivalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [heartImageView, bpmLabel])
        stack.axis = .vertical
        stack.spacing = 8.0
        stack.alignment = .center
        return stack
    }()
    
    private lazy var heartImageView: UIImageView =
    UIImageView(image: .heartIcon)
    
    private lazy var bpmLabel: UILabel =
        .regularTitleLabel(withText: TextConst.bpmText, ofSize: 15.0)
    
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
private extension BPMResultView {
    func commonInit() {
        backgroundColor = .clear
        addSubview(centerStack)
    }

    
    func setupSnapKitConstraints() {
        self.snp.makeConstraints { make in
            make.height.equalTo(LayoutConst.height)
        }
        centerStack.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }

}

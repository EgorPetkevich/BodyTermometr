//
//  BPMView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 26.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class BPMView: UIView {
    
    private enum LayoutConst {
        static let bmpBlackViewSize: CGFloat = 200.0
    }
    
    lazy var bpmValueLabel: UILabel =
        .extraLightTitleLabel(withText: "00", ofSize: 70.0, color: .white)
        .textAlignment(.center)
    lazy var bpmLabel: UILabel =
        .regularTitleLabel(withText: "bpm", ofSize: 15.0, color: .white)
    
    private lazy var heartImageView: UIImageView =
    UIImageView(image: .measuringHeart)
    
    private lazy var bpmBlackView: UIView = UIView().bgColor(.appBlack)
    
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
        
    }
    
}

//MARK: - Private

private extension BPMView {
    
    func commonInit() {
        self.addSubview(bpmBlackView)
        bpmBlackView.addSubview(bpmValueLabel)
        bpmBlackView.addSubview(heartImageView)
        bpmBlackView.addSubview(bpmLabel)
    }
    
    func setupSnapKitConstraints() {
        bpmBlackView.snp.makeConstraints { make in
            make.size.equalTo(LayoutConst.bmpBlackViewSize)
        }
        bpmBlackView.radius = LayoutConst.bmpBlackViewSize / 2
        bpmValueLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(7.0)
            make.right.equalToSuperview().inset(59)
        }
        heartImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(78.0)
            make.right.equalToSuperview().inset(36.5)
        }
        bpmLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(31.0)
            make.bottom.equalToSuperview().inset(75.0)
        }
        
    }
    
}

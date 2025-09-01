//
//  BPMBarControl.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 28.08.25.
//

import UIKit
import SnapKit

final class BPMBarControl: UIControl {
    
    private lazy var slowLabel: UILabel =
        .regularTitleLabel(withText: "Slow", ofSize: 12.0, color: .white)
    private lazy var normalLabel: UILabel =
        .regularTitleLabel(withText: "Normal", ofSize: 12.0, color: .white)
    private lazy var fastLabel: UILabel =
        .regularTitleLabel(withText: "Fast", ofSize: 12.0, color: .white)

    private let trackView = UIView()
    private let slowView = UIView()
    private let normalView = UIView()
    private let fastView = UIView()
    private let thumbView = UIImageView(image: .polygonIcon)


    private var selectedStatus: BPMStatus = .normal {
        didSet {
            moveThumb(to: selectedStatus, animated: true)
            sendActions(for: .valueChanged)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupSnapKitConstrains()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setBPM(_ bpm: Int, animated: Bool = true) {
        let status = BPMStatus(bpm: bpm)
        selectedStatus = status
        moveThumb(to: status, animated: animated)
    }

   
}

//MARK: - Private
private extension BPMBarControl {
    
    func commonInit() {
        addSubview(trackView)
        [slowView, normalView, fastView].forEach { trackView.addSubview($0) }
        addSubview(thumbView)
        slowView.addSubview(slowLabel)
        normalView.addSubview(normalLabel)
        fastView.addSubview(fastLabel)

        trackView.layer.cornerRadius = 10
        trackView.clipsToBounds = true

        slowView.backgroundColor = .appYellow
        normalView.backgroundColor = .appGreen
        fastView.backgroundColor = .appRed
        
       
    }
    
    func setupSnapKitConstrains() {
        slowLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        normalLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        fastLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        trackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
        }

        slowView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(trackView).multipliedBy(1.0/3.0)
        }

        normalView.snp.makeConstraints { make in
            make.leading.equalTo(slowView.snp.trailing)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(trackView).multipliedBy(1.0/3.0)
        }

        fastView.snp.makeConstraints { make in
            make.leading.equalTo(normalView.snp.trailing)
            make.top.bottom.trailing.equalToSuperview()
        }

        thumbView.snp.makeConstraints { make in
            make.top.equalTo(trackView.snp.bottom).offset(-10.0)
            make.centerX.equalTo(normalView.snp.centerX)
        }
    }
    
    private func moveThumb(to status: BPMStatus, animated: Bool) {
        let target: ConstraintRelatableTarget
        switch status {
        case .slow:   target = slowView.snp.centerX
        case .normal: target = normalView.snp.centerX
        case .fast:   target = fastView.snp.centerX
        }

        thumbView.snp.remakeConstraints { make in
            make.top.equalTo(trackView.snp.bottom).offset(-10.0)
            make.centerX.equalTo(target)
            
        }

        if animated {
            UIView.animate(withDuration: 0.2) { self.layoutIfNeeded() }
        } else {
            self.layoutIfNeeded()
        }
    }
    
}

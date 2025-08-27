//
//  CircularProgressView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 26.08.25.
//

import UIKit
import RxSwift
import RxCocoa

final class CircularProgressView: UIView {
    private let track = CAShapeLayer()
    private let progress = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        layer.addSublayer(track)
        layer.addSublayer(progress)
        track.fillColor = UIColor.clear.cgColor
        progress.fillColor = UIColor.clear.cgColor
        track.strokeColor = UIColor.appWhite.cgColor
        progress.strokeColor = UIColor.appButton.cgColor
        track.lineWidth = 30
        progress.lineWidth = 30
        track.lineCap = .round
        progress.lineCap = .round
        progress.strokeEnd = 0
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = min(bounds.width, bounds.height) / 2 - 6
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: -.pi/2, endAngle: 1.5 * .pi, clockwise: true)
        track.path = path.cgPath
        progress.path = path.cgPath
    }

    func setProgress(_ value: Double) {
        progress.strokeEnd = CGFloat(max(0, min(1, value)))
    }
}

//
//  CameraPreviewView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 26.08.25.
//

import UIKit
import AVFoundation

final class CameraPreviewView: UIView {
    private let session: AVCaptureSession

    init(session: AVCaptureSession) {
        self.session = session
        super.init(frame: .zero)
        if let layer = self.layer as? AVCaptureVideoPreviewLayer {
            layer.videoGravity = .resizeAspectFill
            layer.session = session
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
}

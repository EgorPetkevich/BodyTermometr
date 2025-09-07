//
//  PulseManager.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 26.08.25.
//

import AVFoundation
import UIKit
import RxSwift
import RxCocoa


struct VideoSpec {
    var fps: Int32?
    var size: CGSize?
}

typealias ImageBufferHandler = ((_ imageBuffer: CMSampleBuffer) -> ())

class HeartRateManager: NSObject {
    
    var showErrorAlertSubject: PublishSubject<Void> = .init()
    
    let captureSession = AVCaptureSession()
    private var videoDevice: AVCaptureDevice!
    private var videoConnection: AVCaptureConnection!
    private var audioConnection: AVCaptureConnection!
    
    private var isConfigured = false
    private var storedPreferredSpec: VideoSpec?

    var imageBufferHandler: ImageBufferHandler?

    init(preferredSpec: VideoSpec?, previewContainer: CALayer?) {
        super.init()

        storedPreferredSpec = preferredSpec
        // Defer full configuration until we know camera permission
        captureSession.sessionPreset = .low
        // Try to cache a device reference; may be nil on simulator/denied permission
        videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    }
    
    private func configureSessionIfNeeded() {
        guard !isConfigured else { return }

        // Resolve (or re-resolve) the video device
        if videoDevice == nil {
            videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        }
        guard let videoDevice else {
            // No camera device available (e.g., simulator)
            showErrorAlertSubject.onNext(())
            return
        }

        // Apply preferred format if provided
        if let preferredSpec = storedPreferredSpec {
            videoDevice.updateFormatWithPreferredVideoSpec(preferredSpec: preferredSpec)
        }

        // Setup input
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            showErrorAlertSubject.onNext(())
            return
        }
        guard captureSession.canAddInput(videoDeviceInput) else {
            showErrorAlertSubject.onNext(())
            return
        }
        captureSession.addInput(videoDeviceInput)

        // Setup output
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey: NSNumber(value: kCVPixelFormatType_32BGRA)] as [String: Any]
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        let queue = DispatchQueue(label: "com.covidsense.videosamplequeue")
        videoDataOutput.setSampleBufferDelegate(self, queue: queue)
        guard captureSession.canAddOutput(videoDataOutput) else {
            showErrorAlertSubject.onNext(())
            return
        }
        captureSession.addOutput(videoDataOutput)
        videoConnection = videoDataOutput.connection(with: .video)

        isConfigured = true
    }

    func startCapture() {
        print(#function + "\(self.classForCoder)/")
        if captureSession.isRunning {
            #if DEBUG
            print("Capture Session is already running 🏃‍♂️.")
            #endif
            return
        }

        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            self.configureSessionIfNeeded()
            guard self.isConfigured else {
                self.showErrorAlertSubject.onNext(())
                return
            }
            DispatchQueue.global().async {
                self.captureSession.startRunning()
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self = self else { return }
                if granted {
                    self.configureSessionIfNeeded()
                    guard self.isConfigured else {
                        self.showErrorAlertSubject.onNext(())
                        return
                    }
                    DispatchQueue.global().async {
                        self.captureSession.startRunning()
                    }
                } else {
                    self.showErrorAlertSubject.onNext(())
                }
            }
        case .denied, .restricted:
            self.showErrorAlertSubject.onNext(())
        @unknown default:
            self.showErrorAlertSubject.onNext(())
        }
    }

    func stopCapture() {
        #if DEBUG
        print(#function + "\(self.classForCoder)/")
        #endif
        if !captureSession.isRunning {
            #if DEBUG
            print("Capture Session has already stopped.")
            #endif
            return
        }
        captureSession.stopRunning()
    }
}

extension HeartRateManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    // MARK: - Export buffer from video frame
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if connection.videoOrientation != .portrait {
            connection.videoOrientation = .portrait
            return
        }
        if let imageBufferHandler = imageBufferHandler {
            imageBufferHandler(sampleBuffer)
        }
    }
}

extension AVCaptureDevice {
    private func availableFormatsFor(preferredFps: Float64) -> [AVCaptureDevice.Format] {
        var availableFormats: [AVCaptureDevice.Format] = []
        for format in formats
        {
            let ranges = format.videoSupportedFrameRateRanges
            for range in ranges where range.minFrameRate <= preferredFps && preferredFps <= range.maxFrameRate
            {
                availableFormats.append(format)
            }
        }
        return availableFormats
    }

    private func formatWithHighestResolution(_ availableFormats: [AVCaptureDevice.Format]) -> AVCaptureDevice.Format? {
        var maxWidth: Int32 = 0
        var selectedFormat: AVCaptureDevice.Format?
        for format in availableFormats {
            let desc = format.formatDescription
            let dimensions = CMVideoFormatDescriptionGetDimensions(desc)
            let width = dimensions.width
            if width >= maxWidth {
                maxWidth = width
                selectedFormat = format
            }
        }
        return selectedFormat
    }

    private func formatFor(preferredSize: CGSize, availableFormats: [AVCaptureDevice.Format]) -> AVCaptureDevice.Format? {
        for format in availableFormats {
            let desc = format.formatDescription
            let dimensions = CMVideoFormatDescriptionGetDimensions(desc)

            if dimensions.width >= Int32(preferredSize.width) && dimensions.height >= Int32(preferredSize.height) {
                return format
            }
        }
        return nil
    }

    func updateFormatWithPreferredVideoSpec(preferredSpec: VideoSpec) {
        let availableFormats: [AVCaptureDevice.Format]
        if let preferredFps = preferredSpec.fps {
            availableFormats = availableFormatsFor(preferredFps: Float64(preferredFps))
        }
        else {
            availableFormats = formats
        }

        var selectedFormat: AVCaptureDevice.Format?
        if let preferredSize = preferredSpec.size {
            selectedFormat = formatFor(preferredSize: preferredSize, availableFormats: availableFormats)
        } else {
            selectedFormat = formatWithHighestResolution(availableFormats)
        }
        print("selected format: \(String(describing: selectedFormat))")

        if let selectedFormat = selectedFormat {
            do {
                try lockForConfiguration()
            }
            catch let error {
                fatalError(error.localizedDescription)
            }
            activeFormat = selectedFormat

            if let preferredFps = preferredSpec.fps {
                activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: preferredFps)
                activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: preferredFps)
                unlockForConfiguration()
            }
        }
    }

    func toggleTorch(on: Bool) {
        guard hasTorch, isTorchAvailable else {
            print("Torch is not available")
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.lockForConfiguration()
                if on {
                    try self.setTorchModeOn(level: 1.0)
                } else {
                    self.torchMode = .off
                }
                self.unlockForConfiguration()
            } catch {
                print("Torch could not be used: \(error)")
            }
        }
    }


}

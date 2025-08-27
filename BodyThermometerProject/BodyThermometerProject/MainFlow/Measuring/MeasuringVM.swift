//
//  MeasuringVM.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 26.08.25.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa
import CoreImage

protocol MeasuringRouterProtocol {
    func clouseMeasuringGuide()
    func openMeasuringGuide()
    func dismiss()
}

final class MeasuringVM: MeasuringViewModelProtocol {
    
    // Out
    @Subject(value: "00")
    var pulseText: Observable<String>
    @Subject(value: 0.0)
    var progress: Observable<Double>
    @Subject(value: false)
    var measurementStarted: Observable<Bool>
    
    // In
    var viewWillAppear = PublishRelay<Void>()
    var viewDidAppear = PublishRelay<Void>()
    var viewWillDisappear = PublishRelay<Void>()
    var crossButtonTapped = PublishRelay<Void>()

    private var validFrameCounter = 0
    private var hueFilter = Filter()
    private var pulseDetector = PulseDetector()
    private var inputs: [CGFloat] = []
    private var timer = Timer()
    private var isTorchOn = false
    private var elapsed: TimeInterval = 0.0
    private let totalDuration: TimeInterval = 30.0

    private var heartRateManager: HeartRateManager!
    private var hapticEngine = HeartbeatHapticEngine()
    private var router: MeasuringRouterProtocol
    
    private var showGuideDriver: Driver<Bool> {
        UDManagerService.measuringGuideDriver
    }
    private let showFAQRelay = BehaviorRelay<Bool>(value: false)
    private let showResultSubject = PublishSubject<Int>()
    
    // Flags
    private var measurementStartedFlag: Bool = false
    private var pulseTextFlag: String = "00"
    private var progressFlag: Double = 0.0


    private let bag = DisposeBag()
    
    init(router: MeasuringRouterProtocol) {
        self.router = router
        initVideoCapture()
        bindLifecycle()
        bindActions()
    }
    
    private func initVideoCapture() {
        let specs = VideoSpec(fps: 30, size: CGSize(width: 300, height: 300))
        heartRateManager = HeartRateManager(
            preferredSpec: specs,
            previewContainer: nil
        )
        heartRateManager.imageBufferHandler = { [unowned self] (imageBuffer) in
            self.handle(buffer: imageBuffer)
        }
    }
    
    func initCaptureSession() {
       heartRateManager.startCapture()
   }
    

    // MARK: - Bindings
    private func bindLifecycle() {
        viewWillAppear
            .subscribe(onNext: { [weak self] in
                self?.initCaptureSession()
            })
            .disposed(by: bag)
        
        viewDidAppear
            .withLatestFrom(showGuideDriver)
            .subscribe(onNext: { [weak self] show in
                self?.showFAQRelay.accept(show)
            })
            .disposed(by: bag)

        viewWillDisappear
            .subscribe(onNext: { [weak self] in
                self?.stopMeasurement(resetUI: true, turnTorchOff: true)
                self?.heartRateManager.stopCapture()
                self?.updateTorchIfNeeded(status: false)
            })
            .disposed(by: bag)
    }

    private func bindActions() {
        measurementStarted
            .subscribe(onNext: { [weak self] value in
                self?.measurementStartedFlag = value
            })
            .disposed(by: bag)
        pulseText
            .subscribe(onNext: { [weak self] value in
                self?.pulseTextFlag = value
            })
            .disposed(by: bag)
        progress
            .subscribe(onNext: { [weak self] value in
                self?.progressFlag = value
            })
            .disposed(by: bag)
        crossButtonTapped.subscribe(onNext: {[weak self] in
            self?.router.dismiss()
        })
        .disposed(by: bag)
        
        Observable
            .combineLatest(
                _measurementStarted.rx.distinctUntilChanged().map { !$0 },
                showGuideDriver.asObservable()
            )
            .map { notStarted, guideEnabled in
                notStarted && guideEnabled
            }
            
            .bind(to: showFAQRelay)
            .disposed(by: bag)
        
        showFAQRelay
            .subscribe(onNext: { [weak self] show in
                guard let self else { return }
                show ? router.openMeasuringGuide() : router.clouseMeasuringGuide()
            })
            .disposed(by: bag)
    }

    // MARK: - Torch
    private func toggleTorch(status: Bool) {
        guard let device = AVCaptureDevice
            .default(.builtInWideAngleCamera, for: .video,
                     position: .back)
        else { return }
        device.toggleTorch(on: status)
    }

    private func updateTorchIfNeeded(status: Bool) {
        guard status != isTorchOn else { return }
        isTorchOn = status
        toggleTorch(status: status)
    }

    // MARK: - Measurement
    private func startMeasurement() {
        self.updateTorchIfNeeded(status: true)
        elapsed = 0
        _measurementStarted.rx.onNext(true)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.timer.invalidate()
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] t in
                guard let self = self else { return }
                let average = self.pulseDetector.getAverage()
                let pulse = 60.0 / average

                self.elapsed += 1.0
                self._progress.rx.onNext(min(self.elapsed / self.totalDuration, 1.0))
                self.hapticEngine.playHeartbeat()

                if pulse == -60 {
                    // no pulse frame — игнор
                } else {
                    self._pulseText.rx.onNext("\(lroundf(pulse))")
                }

                if self.progressFlag >= 1.0 {
                    t.invalidate()
                    self.finishMeasurement()
                }
            }
        }
    }

    private func finishMeasurement() {
        updateTorchIfNeeded(status: false)
        _measurementStarted.rx.onNext(false)
        let pulse = Int(pulseTextFlag) ?? 0
        
        showResultSubject.onNext(pulse > 0 ? pulse : 0)
        _progress.rx.onNext(0.0)
    }

    private func stopMeasurement(resetUI: Bool, turnTorchOff: Bool) {
        timer.invalidate()
        pulseDetector.reset()
        validFrameCounter = 0
        if turnTorchOff { updateTorchIfNeeded(status: false) }
        _measurementStarted.rx.onNext(false)
        if resetUI {
            _pulseText.rx.onNext("00")
            _progress.rx.onNext(0.0)
        }
    }

    // MARK: - Frames
    fileprivate func handle(buffer: CMSampleBuffer) {
        var redmean: CGFloat = 0.0;
        var greenmean: CGFloat = 0.0;
        var bluemean: CGFloat = 0.0;

        let pixelBuffer = CMSampleBufferGetImageBuffer(buffer)
        let cameraImage = CIImage(cvPixelBuffer: pixelBuffer!)

        let extent = cameraImage.extent
        let inputExtent = CIVector(
            x: extent.origin.x,
            y: extent.origin.y,
            z: extent.size.width,
            w: extent.size.height
        )
        let averageFilter = CIFilter(
            name: "CIAreaAverage",
            parameters: [
                kCIInputImageKey: cameraImage,
                kCIInputExtentKey: inputExtent
            ]
        )!
        let outputImage = averageFilter.outputImage!

        let ctx = CIContext(options:nil)
        let cgImage = ctx.createCGImage(
            outputImage,
            from:outputImage.extent
        )!

        let rawData:NSData = cgImage.dataProvider!.data!
        let pixels = rawData.bytes.assumingMemoryBound(to: UInt8.self)
        let bytes = UnsafeBufferPointer<UInt8>(start:pixels, count:rawData.length)
        var BGRA_index = 0
        for pixel in UnsafeBufferPointer(start: bytes.baseAddress, count: bytes.count) {
            switch BGRA_index {
            case 0:
                bluemean = CGFloat (pixel)
            case 1:
                greenmean = CGFloat (pixel)
            case 2:
                redmean = CGFloat (pixel)
            case 3:
                break
            default:
                break
            }
            BGRA_index += 1
        }

        let hsv = rgb2hsv(
            (
                red: redmean,
                green: greenmean,
                blue: bluemean,
                alpha: 1.0
            )
        )

        if (hsv.1 > 0.5 && hsv.2 > 0.5) {
            DispatchQueue.main.async {
               
                if !self.measurementStartedFlag {
                    self.startMeasurement()
                    self._measurementStarted.rx.onNext(true)
                }
            }
            validFrameCounter += 1
            inputs.append(hsv.0)

            let filtered = hueFilter.processValue(value: Double(hsv.0))
            if validFrameCounter > 60 {
                self.pulseDetector.addNewValue(
                    newVal: filtered,
                    atTime: CACurrentMediaTime()
                )
            }
        } else {
            validFrameCounter = 0
            Task { @MainActor in
                self._measurementStarted.rx.onNext(false)
                self._pulseText.rx.onNext("00")
                self.timer.invalidate()
                self._progress.rx.onNext(0.0)
            }
            pulseDetector.reset()
        }
    }
    
}


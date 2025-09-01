//
//  DateTimePickView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 31.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class DateTimePickView: UIView {
    
    private enum TextConst {
        static let dateText: String = " Date"
        static let timeText: String = " Time"
    }
    
    private enum LayoutConst {
        static let dateViewHeight: CGFloat = 38.0
        static let dateViewRadius: CGFloat = 8.0
        static let timeViewHeight: CGFloat = 38.0
        static let timeViewRadius: CGFloat = 8.0
    }
    
    var dateSabject: PublishSubject<String> = .init()
    var timeSabject: PublishSubject<String> = .init()
    
    var dateTap: Observable<Void> {
        dateCoverButton.rx.tap.asObservable()
    }
    
    var timeTap: Observable<Void> {
        timeCoverButton.rx.tap.asObservable()
    }
    
    private lazy var dateTitleLabel: UILabel =
        .mediumTitleLabel(withText: TextConst.dateText, ofSize: 18.0)
    lazy var dateLabel: UILabel =
        .regularTitleLabel(withText: getCurrenDate(), ofSize: 15.0)
    private lazy var dateView: UIView = UIView().bgColor(.appWhite)
    private lazy var dateArrow: UIImageView =
    UIImageView(image: .arrowIconRightBlack)
    private lazy var dateCoverButton: UIButton = UIButton()
    
    private lazy var timeTitleLabel: UILabel =
        .mediumTitleLabel(withText: TextConst.timeText, ofSize: 18.0)
    lazy var timeLabel: UILabel =
        .regularTitleLabel(withText: getCurrenTime(), ofSize: 15.0)
    private lazy var timeView: UIView = UIView().bgColor(.appWhite)
    private lazy var timeArrow: UIImageView =
    UIImageView(image: .arrowIconRightBlack)
    private lazy var timeCoverButton: UIButton = UIButton()
    
    private var bag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupSnapKitConstrains()
        bind()
        bindButtons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        dateSabject
            .bind(to: dateLabel.rx.text)
            .disposed(by: bag)
        timeSabject
            .bind(to: timeLabel.rx.text)
            .disposed(by: bag)
    }
    
    private func bindButtons() {
        dateCoverButton.rx.controlEvent(.touchDown)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.dateView.alpha = 0.7
                }
            })
            .disposed(by: bag)
        
        dateCoverButton.rx.controlEvent(
            [.touchUpInside,
            .touchUpOutside,
            .touchCancel,
            .touchDragExit])
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.dateView.alpha = 1.0
                }
            })
            .disposed(by: bag)
        
        timeCoverButton.rx.controlEvent(.touchDown)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.timeView.alpha = 0.7
                }
            })
            .disposed(by: bag)
        
        timeCoverButton.rx.controlEvent(
            [.touchUpInside,
            .touchUpOutside,
            .touchCancel,
            .touchDragExit])
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.timeView.alpha = 1.0
                }
            })
            .disposed(by: bag)
    }
    
}

//MARK: - Private
private extension DateTimePickView {
    
    func commonInit() {
        self.addSubview(dateTitleLabel)
        self.addSubview(dateView)
        dateView.addSubview(dateLabel)
        dateView.addSubview(dateArrow)
        dateView.addSubview(dateCoverButton)
        dateCoverButton.layer.zPosition = .greatestFiniteMagnitude
        
        self.addSubview(timeTitleLabel)
        self.addSubview(timeView)
        timeView.addSubview(timeLabel)
        timeView.addSubview(timeArrow)
        timeView.addSubview(timeCoverButton)
        timeCoverButton.layer.zPosition = .greatestFiniteMagnitude
    }
    
    func setupSnapKitConstrains() {
        dateTitleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
        }
        dateView.snp.makeConstraints { make in
            make.top.equalTo(dateTitleLabel.snp.bottom).offset(8.0)
            make.height.equalTo(LayoutConst.dateViewHeight)
            make.bottom.left.equalToSuperview()
            make.right.equalTo(self.snp.centerX).inset(4.0)
        }
        dateView.radius = LayoutConst.dateViewRadius
        dateLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(16.0)
        }
        dateArrow.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(8.0)
        }
        dateCoverButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        timeTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(timeView.snp.leading)
        }
        timeView.snp.makeConstraints { make in
            make.height.equalTo(LayoutConst.timeViewHeight)
            make.top.equalTo(timeTitleLabel.snp.bottom).offset(8.0)
            make.bottom.right.equalToSuperview()
            make.left.equalTo(self.snp.centerX).offset(4.0)
        }
        timeView.radius = LayoutConst.timeViewRadius
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(16.0)
        }
        timeArrow.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(8.0)
        }
        timeCoverButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func getCurrenDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: Date())
    }
    
    func getCurrenTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: Date())
    }
    
}

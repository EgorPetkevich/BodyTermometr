//
//  DatePickerVC.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 1.09.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class DatePickerVC: UIViewController {
    
    enum DatePickerType {
        case date
        case time
    }
    
    private enum TextConst {
        static let selectDateTitleText: String = "Select Date"
        static let selectTimeTitleText: String = "Select Time"
        static let clouseButtonText: String = "Close"
        static let confirmButtonText: String = "Confirm"
    }
    
    private enum LayoutConst {
        static let confirmButtonSize: CGSize = .init(width: 200, height: 52)
    }
    
    private let bag = DisposeBag()
    private let _selectedDateSubject: PublishSubject<Date>
    private let type: DatePickerType

    private let initialDate: Date
    private let minDate: Date?
    private let maxDate: Date?

    let selectedDate: Observable<Date>

    init(
        initial: Date = Date(),
        type: DatePickerType,
        minimumDate: Date? = nil,
        maximumDate: Date? = Date()
    ) {
        _selectedDateSubject = PublishSubject<Date>()
        selectedDate = _selectedDateSubject.asObservable()
        self.type = type
        self.initialDate = initial
        self.minDate = minimumDate
        self.maxDate = maximumDate
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = false
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBg
        view.layer.cornerRadius = 32
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        setupUI()
        setupInitialValues()
        bind()
    }

    private lazy var titleLabel: UILabel =
        .mediumTitleLabel(withText: "", ofSize: 24.0)

    private lazy var closeButton: UIButton = UIButton(type: .system)
        .setTitle(TextConst.clouseButtonText)
        .setFont(.appRegularFont(ofSize: 12.0))
        .setTintColor(.appGrey)

    private lazy var picker: UIDatePicker = {
        let p = UIDatePicker()
        p.datePickerMode = .date
        p.locale = .current
        p.calendar = .current
        p.timeZone = .current
        p.preferredDatePickerStyle = .wheels
        p.setContentCompressionResistancePriority(.required, for: .vertical)
        return p
    }()

    private lazy var confirmButton: UIButton =
    UIButton(type: .system)
        .setTitle(TextConst.confirmButtonText)
        .setTintColor(.appBlack)
        .setBgColor(.appButton)

    private let containerView = UIView()

}

// MARK: - Setup
private extension DatePickerVC {
    func setupUI() {
        view.backgroundColor = .appBg

        containerView.backgroundColor = .appBg
        containerView.layer.cornerRadius = 32
        containerView.layer.masksToBounds = true
        view.addSubview(containerView)

        containerView.addSubview(titleLabel)
        containerView.addSubview(closeButton)
        containerView.addSubview(picker)
        containerView.addSubview(confirmButton)

        containerView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(38.0)
            make.centerX.equalToSuperview()
        }

        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(24.0)
            make.right.equalToSuperview().inset(16.0)
        }

        picker.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.lessThanOrEqualTo(confirmButton.snp.top).offset(-12)
            make.height.greaterThanOrEqualTo(216)
        }

        confirmButton.snp.makeConstraints { make in
            make.size.equalTo(LayoutConst.confirmButtonSize)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(26.0)
        }
        confirmButton.radius = LayoutConst.confirmButtonSize.height / 2
    }

    func setupInitialValues() {
        switch type {
        case .date:
            titleLabel.text = TextConst.selectDateTitleText
            picker.datePickerMode = .date
        case .time:
            titleLabel.text = TextConst.selectTimeTitleText
            picker.datePickerMode = .time
        }
        picker.preferredDatePickerStyle = .wheels
        if case .date = type {
            picker.minimumDate = minDate
            picker.maximumDate = maxDate
        }
        picker.date = initialDate
        picker.minuteInterval = 1
    }

    func bind() {
        closeButton.rx.tap
            .bind(with: self) { owner, _ in owner.dismiss(animated: true) }
            .disposed(by: bag)

        confirmButton.rx.tap
            .map { [unowned self] in self.picker.date }
            .do(onNext: { [weak self] _ in self?.dismiss(animated: true) })
            .bind(to: _selectedDateSubject)
            .disposed(by: bag)
    }
}

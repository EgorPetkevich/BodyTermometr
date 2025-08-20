//
//  UserAgeTextFieldView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 20.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class UserAgeTextFieldView: UIView {
    
    private enum TextConst {
        static let titleText: String = "Age"
        static let placeholderText: String = "enter your age"
    }
    
    private enum LayoutConst {
        static let textFieldHeight: CGFloat = 60.0
    }
    
    private let ageDelegate = AgeTextDelegate(maxAge: 120)
    
    var textFieldTextObservable: Observable<String?>
    { textField.rx.text.asObservable() }
    
    var textFieldText: String? {
        get { textField.text }
        set { textField.text = newValue }
    }
    
    private let bag = DisposeBag()
    
    private lazy var titleLabel: UILabel =
        .regularTitleLabel(withText: TextConst.titleText,
                           ofSize: 12.0,
                           color: .appGrey)
    
    private lazy var textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = TextConst.placeholderText
        tf.textColor = .appBlack
        tf.backgroundColor = .appWhite
        tf.keyboardType = .numberPad
        let paddingView = UIView(frame: .init(x: 0, y: 0, width: 16, height: 0))
        tf.leftView = paddingView
        tf.leftViewMode = .always
        return tf
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupSnapKitConstraints()
        configureBehavior()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private
private extension UserAgeTextFieldView {
    func commonInit() {
        backgroundColor = .clear
        addSubview(titleLabel)
        addSubview(textField)
    }
    
    func setupSnapKitConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16.0)
            make.top.equalToSuperview()
        }
        textField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(LayoutConst.textFieldHeight)
            make.top.equalTo(titleLabel.snp.bottom).offset(8.0)
            make.bottom.equalToSuperview()
        }
        textField.radius = 16.0
    }
    
    func configureBehavior() {
        textField.keyboardType = .numberPad
        textField.delegate = ageDelegate
    }
    
}

final class AgeTextDelegate: NSObject, UITextFieldDelegate {
    private let maxAge: Int

    init(maxAge: Int) {
        self.maxAge = maxAge
        super.init()
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        if string.isEmpty { return true }

        if !CharacterSet.decimalDigits
            .isSuperset(of: CharacterSet(charactersIn: string)) {
            return false
        }

        let current = textField.text ?? ""
        guard let r = Range(range, in: current) else { return false }

        var candidate = current.replacingCharacters(in: r, with: string)

        candidate = candidate.filter(\.isNumber)
        while candidate.count > 1 && candidate.first == "0" {
            candidate.removeFirst()
        }
        
        if candidate.count > 3 { return false }

        guard !candidate.isEmpty else { return true }

        if let n = Int(candidate), n <= maxAge {
            return true
        } else {
            return false
        }
    }
}

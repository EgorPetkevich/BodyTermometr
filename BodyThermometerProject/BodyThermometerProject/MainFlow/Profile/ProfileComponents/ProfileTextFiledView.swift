//
//  ProfileTextFiledView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 20.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class ProfileTextFiledView: UIView {
    
    private enum TextConst {
        static func titleText(for type: TextFieldType) -> String {
            switch type {
            case .name: "Name"
            case .age:  "Age"
            }
        }
        static func placeholderText(for type: TextFieldType) -> String {
            switch type {
            case .name: "enter your name"
            case .age:  "enter your age"
            }
        }
    }
    
    private enum LayoutConst {
        static let textFieldHeight: CGFloat = 60.0
    }

    enum TextFieldType {
        case name
        case age(max: Int = 120, min: Int = 0) // можно задать границы
    }
    
    var textFieldTextObservable: Observable<String?>
    { textField.rx.text.asObservable() }
    
    var textFieldText: String? {
        get { textField.text }
        set { textField.text = newValue }
    }
    
    private let bag = DisposeBag()
    private var currentType: TextFieldType
    
    private lazy var titleLabel: UILabel =
        .regularTitleLabel(withText: TextConst.titleText(for: currentType),
                           ofSize: 12.0,
                           color: .appGrey)
    
    private lazy var textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = TextConst.placeholderText(for: currentType)
        tf.textColor = .appBlack
        tf.backgroundColor = .appWhite
        tf.keyboardType = getKeyboardType()
        let paddingView = UIView(frame: .init(x: 0, y: 0, width: 16, height: 0))
        tf.leftView = paddingView
        tf.leftViewMode = .always
        tf.autocorrectionType = .no
        tf.spellCheckingType = .no
        switch currentType {
        case .name:
            tf.autocapitalizationType = .words
        case .age:
            tf.autocapitalizationType = .none
        }
        return tf
    }()
    
    init(type: TextFieldType) {
        self.currentType = type
        super.init(frame: .zero)
        commonInit()
        setupSnapKitConstraints()
        configureBehavior()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Private
private extension ProfileTextFiledView {
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
    
    func getKeyboardType() -> UIKeyboardType {
        switch currentType {
        case .name: return .default
        case .age:  return .numberPad
        }
    }
    
    func configureBehavior() {
        switch currentType {
        case .name:
            
            break
            
        case .age(let max, let min):
            addDoneToolbar(to: textField)
            
            textField.rx.text.orEmpty
                .map { $0.filter(\.isNumber) }
                .map { String($0.prefix(3)) }
                .map { text -> String in                
                    guard let n = Int(text) else { return "" }
                    return String(self.swiftClamp(n, min, max))
                }
                .distinctUntilChanged()
                .bind(to: textField.rx.text)
                .disposed(by: bag)
        }
    }
    
    @inline(__always)
    func swiftClamp(_ value: Int, _ minVal: Int, _ maxVal: Int) -> Int {
        return max(minVal, min(value, maxVal))
    }
    
    func addDoneToolbar(to tf: UITextField) {
        let toolbar = UIToolbar(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneTapped))
        toolbar.items = [flex, done]
        tf.inputAccessoryView = toolbar
    }
    
    @objc func doneTapped() {
        endEditing(true)
    }
}


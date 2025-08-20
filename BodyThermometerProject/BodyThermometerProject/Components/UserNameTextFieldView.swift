//
//  UserNameTextFieldView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 20.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class UserNameTextFieldView: UIView {
    
    private enum TextConst {
        static let titleText: String = "Name"
        static let placeholderText: String = "enter your name"
    }
    
    private enum LayoutConst {
        static let textFieldHeight: CGFloat = 60.0
    }
    
    private lazy  var titleLabel: UILabel =
        .regularTitleLabel(withText: TextConst.titleText,
                           ofSize: 12.0, color: .appGrey)
    
    private lazy var textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = TextConst.placeholderText
        tf.textColor = .appBlack
        tf.backgroundColor = .appWhite
        tf.keyboardType = .default
        let paddingView = UIView(frame: .init(x: 0, y: 0,
                                              width: 16, height: 0))
        tf.leftView = paddingView
        tf.leftViewMode = .always
        return tf
    }()
    
    var textFieldTextObservable: Observable<String?>
    { textField.rx.text.asObservable() }
    
    var textFieldText: String? {
        get { textField.text }
        set { textField.text = newValue }
    }
    
    private let bag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupSnapKitConstraints()
        configureBehavior()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.autocapitalizationType = .words
        textField.textContentType = .name
        
        let maxLen = 20
        
        textField.rx.text.orEmpty
            .map { [weak self] in self?.normalizeName($0, maxLen: maxLen) ?? "" }
            .distinctUntilChanged()
            .bind(to: textField.rx.text)
            .disposed(by: bag)
    }

    
    func normalizeName(_ s: String, maxLen: Int) -> String {
        var t = s
        t = t.replacingOccurrences(of: "[^\\p{L}\\p{M}\\s\\-']",
                                   with: "",
                                   options: .regularExpression)

        t = t.replacingOccurrences(of: "\\s+",
                                   with: " ",
                                   options: .regularExpression)
        t = t.replacingOccurrences(of: "([-'])\\1+",
                                   with: "$1",
                                   options: .regularExpression)

        let trimSet = CharacterSet(charactersIn: " -'")
        t = t.trimmingCharacters(in: trimSet)

        if t.count > maxLen {
            t = String(t.prefix(maxLen))
        }

        t = t.lowercased(with: Locale.current)
            .split(separator: " ")
            .map { word -> String in
                let w = String(word)
                var chars = Array(w)
                if let first = chars.first {
                    chars[0] = Character(String(first).uppercased())
                }
                for i in 1..<chars.count {
                    if chars[i-1] == "-" || chars[i-1] == "'" {
                        chars[i] = Character(String(chars[i]).uppercased())
                    }
                }
                return String(chars)
            }
            .joined(separator: " ")

        return t
    }
    
}

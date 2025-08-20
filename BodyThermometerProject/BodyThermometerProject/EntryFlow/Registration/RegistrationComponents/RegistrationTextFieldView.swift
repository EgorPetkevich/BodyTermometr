//
//  RegistrationTextFieldView.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 17.08.25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class RegistrationTextFieldView: UIView {
    
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
        case age
    }
    
    private let ageDelegate = AgeTextDelegate(maxAge: 120)
    
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
private extension RegistrationTextFieldView {
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
            
            
        case .age:
            textField.keyboardType = .numberPad
            textField.delegate = ageDelegate
            addDoneToolbar(to: textField)
        }
    }
    
    @inline(__always)
    func swiftClamp(_ value: Int, _ minVal: Int, _ maxVal: Int) -> Int {
        return max(minVal, min(value, maxVal))
    }
    
    func normalizeName(_ s: String, maxLen: Int) -> String {
        var t = s

        // 1) Оставляем только буквы (любой алфавит), пробел, дефис, апостроф
        // \p{L} — буквы Юникода, \p{M} — комбинируемые диакритики (для акцентированных букв)
        t = t.replacingOccurrences(of: "[^\\p{L}\\p{M}\\s\\-']",
                                   with: "",
                                   options: .regularExpression)

        // 2) Схлопываем группы из пробелов/дефисов/апострофов до одного символа своей группы
        t = t.replacingOccurrences(of: "\\s+",
                                   with: " ",
                                   options: .regularExpression)
        t = t.replacingOccurrences(of: "([-'])\\1+",
                                   with: "$1",
                                   options: .regularExpression)

        // 3) Убираем лидирующие/хвостовые пробелы, дефисы, апострофы
        let trimSet = CharacterSet(charactersIn: " -'")
        t = t.trimmingCharacters(in: trimSet)

        // 4) Ограничиваем длину
        if t.count > maxLen {
            t = String(t.prefix(maxLen))
            // если обрезали на середине мультибайтового символа — prefix уже безопасен для Swift.String
        }

        // 5) Title Case (каждое слово с заглавной). Locale.current — чтобы корректно работать с кириллицей/латиницей.
        t = t.lowercased(with: Locale.current)
            .split(separator: " ")
            .map { word -> String in
                // дополнительно поднимем буквы после дефиса/апострофа: Jean-luc -> Jean-Luc, O'neill -> O'Neill
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

final class AgeTextDelegate: NSObject, UITextFieldDelegate {
    private let maxAge: Int

    init(maxAge: Int) {
        self.maxAge = maxAge
        super.init()
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        // Разрешаем удаление
        if string.isEmpty { return true }

        // Только цифры
        if !CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)) {
            return false
        }

        let current = textField.text ?? ""
        guard let r = Range(range, in: current) else { return false }

        // Кандидат на результат после ввода/вставки
        var candidate = current.replacingCharacters(in: r, with: string)

        // Фильтруем нецифровые (на всякий) и убираем лидирующие нули (кроме единственного нуля)
        candidate = candidate.filter(\.isNumber)
        while candidate.count > 1 && candidate.first == "0" {
            candidate.removeFirst()
        }

        // Максимум 3 символа
        if candidate.count > 3 { return false }

        // Пустую строку (после удаления) разрешаем
        guard !candidate.isEmpty else { return true }

        // Проверка числового диапазона
        if let n = Int(candidate), n <= maxAge {
            return true
        } else {
            // Если превысит max — запрещаем ввод
            return false
        }
    }
}
